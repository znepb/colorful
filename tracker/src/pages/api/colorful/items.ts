import { NextApiRequest, NextApiResponse } from "next";
import fs from "fs";
import { Colorful } from "@/types";

export default function handler(req: NextApiRequest, res: NextApiResponse) {
  if (req.method !== "GET") {
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

  const data: Colorful = JSON.parse(
    fs.readFileSync("data/colorful.json", "utf8")
  );

  res.status(200).json(data);
}
