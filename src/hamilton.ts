import { readFile, writeFile } from "fs/promises";
import { Entry } from "./song";

interface Word {
  rex: RegExp,
  label: string
}

interface Record<T> {
  [key: string]: T
}


export const get_songs = (): Promise<Entry[]> =>
  readFile("./lyrics.json", "utf8").then(JSON.parse);

const count_hamilton = async (
  song: Entry,
  words: Word[],
): Promise<Record<number>> => words.reduce((r, {rex, label}) => ({...r, [label]: (song.text.match(rex) || []).length }), {} as Record<number>)  


const main = async () => {
  const songs = await get_songs()

  let cnt = 0;
  const cnts: [Record<number>, string][] = [];
  const words: Word[] = [
    {
      label: "My Shot",
      rex:  /my shot/gi
    },
    {
      label: "Wait for it",
      rex:  /wait/gi
    },
    {
      label: 'Satisfied',
      rex: /satisfied/gi
    }
  ]

  for (const song of songs) {
    const c = await count_hamilton(song, words);
    
    const pl: [Record<number>, string] = [c, song.name]
    console.log(pl)
    cnts.push(pl);
  }

  console.log(cnt);
  const csv = cnts.reduce(
    (r, [c, l]) =>
      (r += `${l};${Object.values(c).join(';')}\n`),
    `song;${words.map(({label}) => label).join(';')}\n`
  );
  await writeFile("./counts.csv", csv, {
    encoding: "utf-8",
  });
};

main()
  .catch(console.error)
  .finally(() => process.exit());
