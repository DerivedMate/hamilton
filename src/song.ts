export interface EntryMeta {
  characters: string[]
  url: string
}

export interface Entry {
  i: number
  name: string
  meta: EntryMeta
  text: string
}

export enum SongType {
  Monologue, // no speaker found; i.e.: "youll be back," "burn"
  Dialogue, // more than one speaker
}
export interface Song {
  speakers: string[]
  lines: Line[]
}

export enum LineType {
  Monologue, // no speaker found; i.e.: "youll be back," "burn"
  SingleSpeaker, // just one speaker
  Accompanied, // [S0 (S1) ((S2)) &c] = S0 by [S1, S2, &c]
}
export interface Line {}
