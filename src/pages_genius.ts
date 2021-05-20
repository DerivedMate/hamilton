import { readFile, writeFile } from 'fs/promises'
import {
  chromium as browser_inst,
  ChromiumBrowser as Browser,
} from 'playwright'

interface URL {
  i: number
  url: string
}

interface ResS {
  done: true
  text: LineElem[]
  title: string
}

interface ResF {
  done: false
  reason: string
}

type Res = ResS | ResF

interface LineElem {
  speaker_line: string
  text: string[]
}
interface LineReducer {
  head: LineElem
  aggregate: LineElem[]
}

export interface RawSong {
  lines: LineElem[]
  title: string
  origin: string
  i: number
}

interface SelectorSet {
  tester: string
  cleaning_root: string
  text_root: string
  title_selector: string
  irrelevant_selectors: string[]
}

export const get_links = (): Promise<string[]> =>
  readFile('./urls.json', 'ascii').then(JSON.parse)

/**
 * @on_success {Continue}
 * @on_fail {Retry}
 */
const download = (browser: Browser, url: string): Promise<Res> =>
  new Promise<Res>(async (res, rej) => {
    const selectors: SelectorSet[] = [
      {
        tester: 'defer-compile',
        cleaning_root: '.lyrics p',
        text_root: '.lyrics p',
        title_selector: 'h1',
        irrelevant_selectors: ['defer-compile'],
      },
      {
        tester: `[class^="Lyrics__Container"]`,
        cleaning_root: `[class*="Lyrics__Root"]`,
        text_root: `[class*="Lyrics__Root"]`,
        title_selector: 'h1',
        irrelevant_selectors: [
          `[class^="InreadAd__Container"]`,
          `[class*="RightSidebar"]`,
        ],
      },
    ]

    const page = await browser.newPage()
    page.setDefaultNavigationTimeout(0)
    page.setDefaultTimeout(0)

    await page.goto(url, {
      waitUntil: 'load',
    })

    // --------------------[ Detect the selector types ]-------------------- //
    console.info('determining the selector set')

    const { found, i } = await Promise.all(
      selectors.map(s =>
        page
          .evaluate(([test]) => !!document.querySelector(test), [s.tester])
          .catch(() => false)
      )
    )
      .then(r => ({ found: true, i: r.indexOf(true) }))
      .catch(() => ({ found: false, i: -1 }))

    if (!found) {
      return rej({
        done: false,
        reason: 'uncovered selectors',
      } as Res)
    }

    // --------------------[ Setting the selectors ]-------------------- //

    console.info('Found valid selectors:')
    console.dir(selectors[i], { colors: true })
    const { cleaning_root, text_root, title_selector, irrelevant_selectors } =
      selectors[i]
    // --------------------[ Remove irrelevant elements ]-------------------- //
    await page.evaluate(
      ([root, selectors]: [string, string[]]) =>
        selectors.forEach(s =>
          document
            .querySelector(root)
            ?.querySelectorAll(s)
            ?.forEach(n => n.remove())
        ),
      [cleaning_root, irrelevant_selectors] as [string, string[]]
    )

    // --------------------[ Scrape the text ]-------------------- //
    const reduced = await page
      .innerText(text_root)
      .then(raw => raw.split('\n'))
      .then(lines =>
        lines.reduce(
          (h, a): LineReducer => {
            // --------------------[ Ignore empty lines ]-------------------- //
            if (a.length === 0) return h

            // --------------------[ Start a new speech ]-------------------- //
            if (/^\[.*\]$/i.test(a))
              return {
                head: {
                  speaker_line: a.slice(1, -1),
                  text: [],
                },
                aggregate: h.head.speaker_line
                  ? [...h.aggregate, h.head]
                  : h.aggregate,
              }

            // --------------------[ Add a new line ]-------------------- //
            return {
              ...h,
              head: {
                ...h.head,
                text: [...h.head.text, a],
              },
            }
          },
          {
            head: {
              speaker_line: '',
              text: [],
            },
            aggregate: [],
          } as LineReducer
        )
      )

    const raw = [...reduced.aggregate, reduced.head]

    // --------------------[ Get the title ]-------------------- //
    const title = await page.innerText(title_selector)

    await page.close()
    res({
      done: true,
      text: raw,
      title,
    })
  })

const loop = async () => {
  const browser = await browser_inst.launch({
    timeout: 0,
  })

  const urls: URL[] = await get_links().then(vs =>
    vs.map((url, i) => ({ url, i }))
  )
  const processed: RawSong[] = []

  while (urls) {
    const next = urls.pop()
    if (!next) break
    console.log(`left: ${urls.length}; current: ${next.url}`)

    const res = await download(browser, next.url).catch(e => {
      console.error(e)
      return {
        done: false,
        reason: e,
      } as Res
    })

    if (!res.done) {
      console.error(res.reason)
      urls.unshift(next)
    } else
      processed.push({
        title: res.title,
        lines: res.text,
        i: next.i,
        origin: next.url,
      } as RawSong)
  }

  await browser.close()

  await writeFile(
    './lyrics.json',
    JSON.stringify(
      processed.sort((a, b) => a.i - b.i),
      null,
      2
    ),
    {
      encoding: 'utf8',
    }
  )
}

const test = async (url: string) => {
  const browser = await browser_inst.launch({
    headless: false,
    slowMo: 1000,
  })

  console.dir(await download(browser, url), {
    colors: true,
    depth: 5,
  })
  await browser.close()
}

loop()
  // test("https://genius.com/Phillipa-soo-burn-lyrics")
  .catch(console.error)
  .finally(() => process.exit(0))
