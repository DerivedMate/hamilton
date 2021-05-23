import { readFile, writeFile } from 'fs/promises'
import { safe_wrapp } from '../helpers'
import { RawSong } from './pages_genius'

const minifi_js = (path: string, dist: string) =>
  readFile(path, {
    encoding: 'utf-8',
  })
    .then(c => JSON.stringify(JSON.parse(c)))
    .then(json =>
      writeFile(dist, json, {
        encoding: 'utf-8',
      })
    )

// minifi_js('lyrics.json', 'lyrics.min.json').catch(console.error)
const destile_speakers = (path: string, dist: string) =>
  readFile(path, {
    encoding: 'utf8',
  })
    .then(c => JSON.parse(c) as RawSong[])
    .then(songs =>
      songs.reduce(
        (r, s) => [...r, ...s.lines.map(l => l.speaker_line)],
        [] as string[]
      )
    )
    .then(speakers => [...new Set(speakers)])
    .then(speakers =>
      writeFile(dist, JSON.stringify(speakers, null, 2), {
        encoding: 'utf8',
      })
    )

// destile_speakers('./lyrics.min.json', './speakers.json').catch(console.error)

const find_speaker_songs = (path: string, dist: string, filters: RegExp[]) =>
  readFile(path, {
    encoding: 'utf8',
  })
    .then(c => JSON.parse(c) as RawSong[])
    .then(songs =>
      // --------------------[ Find the matching songs ]-------------------- //
      songs.filter(s =>
        s.lines.some(l => filters.every(m => m.test(l.speaker_line)))
      )
    )
    .then(songs =>
      // --------------------[ Save to a file ]-------------------- //
      writeFile(dist, JSON.stringify(songs, null, 2), {
        encoding: 'utf8',
      })
    )
// BURR AND ENSEMBLE & WASHINGTON/ELIZA/ANGELICA/MARIA

safe_wrapp(
  find_speaker_songs('./lyrics/heights.json', './heights_to_inspect.temp.json', [
    /\w+ and \w+/i,
  ])
)


/*;(() => {
  console.dir(process.argv)
})()*/