import { readdir } from "fs/promises"
;(async () => {
  readdir("./").then(console.dir)
})()