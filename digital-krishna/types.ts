
export interface Verse {
  chapter: number;
  verse: number;
  text: string;
  translation: string;
  transliteration: string;
}

export interface Message {
  id: string;
  role: 'user' | 'krishna';
  text: string;
  timestamp: number;
  verses?: Verse[];
}

export interface GitaData {
  verses: Verse[];
}
