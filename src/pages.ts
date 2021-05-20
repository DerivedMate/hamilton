import { readFile, writeFile } from 'fs/promises'
import { firefox, FirefoxBrowser } from 'playwright'
import { Entry } from './song' 

enum Reason {
  NullDist = 'null dist',
}

interface ResFail {
  done: false
}

interface ResSuccessful {
  done: true
  name: string
  text: string
  characters: string[]
}

type Res = ResFail | ResSuccessful

interface URL {
  i: number
  url: string
}

export const get_links = (): Promise<string[]> =>
  readFile('./urls.json', 'ascii').then(JSON.parse)

const download = (browser: FirefoxBrowser, url: string): Promise<Res> =>
  new Promise(async (res, rej) => {
    const root_selector =
      'table.contentpaneopen:nth-child(2) > tbody:nth-child(1) > tr:nth-child(1) > td:nth-child(1)'
    const p = await browser.newPage()
    const cont = await p
      .goto(url, {
        waitUntil: 'domcontentloaded',
      })
      .then(() => true)
      .catch(e => {
        console.error(e)
        res({
          done: false,
        })
        return false
      })

    if (!cont) {
      await p.close()
      return
    }
    // Clean the meta
    const characters = await p
      .evaluate(
        ([root_selector]) => {
          const root = document.querySelector(root_selector)
          if (!root) return
          const meta = root.querySelector('em')?.innerText.trim() || ''

          root.querySelector('p')?.remove()
          root.querySelectorAll('em').forEach(e => e.remove())

          return meta.toLowerCase()
        },
        [root_selector]
      )
        .then(t => /performed\s*by\s*(.*)$/i.exec(t || ''))
        .then(r => (r ? r[1].split(',').map(t => t.trim()) : []))
        .then(rs =>
          rs
            .map(r => ({ alias: /\(([\w\s]+)\)/gi.exec(r), r }))
            .map(({ alias, r }) => (alias ? alias[1].trim() : r))
        )

    const text = await p
      .innerText(root_selector, {
        timeout: 100000,
      })
      .then(t =>
        t
          .trim()
          .replace(/\n+/gim, '\n')
          .replace(/\s+/gim, ' ')
          .replace(/\([\w\s]+\.\)[\s\n]*/gim, '')
          .replace(/\[\s?thanks.*$/gim, '')
          .replace(/read more:.*$/gim, '')
          .trim()
      )

    const dist_match =
      /\d+-(?:hamilton-)?([\w-]+)-lyrics(?:-hamilton)?(?:-the-musical)?\.html/gi.exec(
        url
      )

    if (!dist_match) {
      rej(Reason.NullDist)
      await p.close()
      return
    }

    await p.close()
    res({
      done: true,
      name: dist_match[1].split('-').join(' '),
      text,
      characters,
    })
  })

const do_downloading = async () => {
  let urls: URL[] = await get_links().then(urls =>
    urls.map((url, i) => ({ i, url }))
  )
  const data: Entry[] = []
  const browser = await firefox.launch()

  while (urls.length) {
    const next = urls.pop()
    if (!next) break
    console.log(`LEFT: ${urls.length}; CURRENT: ${next.url}`)

    const res = await download(browser, next.url).catch(
      () =>
        ({
          done: false,
          location: '',
        } as Res)
    )

    if (!res.done) urls.push(next)
    else
      data.push({
        i: next.i,
        name: res.name,
        meta: {
          url: next.url,
          characters: res.characters,
        },
        text: res.text,
      })
  }

  await writeFile(
    './lyrics.json',
    JSON.stringify(data.sort((a, b) => a.i - b.i)),
    {
      encoding: 'utf8',
    }
  )
}

do_downloading()
  .catch(console.error)
  .finally(() => process.exit())
