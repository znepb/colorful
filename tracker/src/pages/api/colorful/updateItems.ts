import { NextApiRequest, NextApiResponse } from "next";
import fs from "fs";
import { Colorful } from "@/types";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "POST") {
    res.status(405).json({
      error: "Method not allowed",
    });
    return;
  }

  if (req.headers.authorization !== `Bearer ${process.env.AUTHORIZATION}`) {
    res.status(401).json({
      error: "Unauthorized",
    });
    return;
  }

  const { dyes, wool, ingredients } = req.body;

  if (!dyes || !wool || !ingredients) {
    res.status(400).json({
      error: "Missing required fields",
    });
    return;
  }

  const data = fs.readFileSync("data/colorful.json", "utf8");
  const colorful: Colorful = JSON.parse(data);

  colorful.dyes = dyes;
  colorful.wool = wool;
  colorful.ingredients = ingredients;
  colorful.lastUpdated = new Date().toISOString();

  fs.writeFileSync("data/colorful.json", JSON.stringify(colorful));

  res.status(200).json(colorful);
}
