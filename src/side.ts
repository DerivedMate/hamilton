import { readFile, writeFile } from 'fs/promises'

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


minifi_js('lyrics.json', 'lyrics.min.json').catch(console.error)
