export type ColorfulEvents =
  | "start"
  | "purchase"
  | "cartridgeRefill"
  | "jobComplete"
  | "stall"
  | "lowItems";

export interface Colorful {
  error?: string;
  lastUpdated: string;
  dyes: {
    white: number;
    black: number;
    red: number;
    yellow: number;
    green: number;
    blue: number;
    brown: number;
  };
  wool: {
    white: number;
    orange: number;
    magenta: number;
    light_blue: number;
    yellow: number;
    lime: number;
    pink: number;
    gray: number;
    light_gray: number;
    cyan: number;
    purple: number;
    blue: number;
    brown: number;
    green: number;
    red: number;
    black: number;
  };
  ingredients: {
    sand: number;
    gravel: number;
    glass: number;
    terracotta: number;
  };
  events: {
    type: ColorfulEvents;
    time: string;
    data: { [key: string]: string | boolean | number };
  }[];
}
