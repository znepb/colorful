import Image from "next/image";
import { Inter } from "next/font/google";
import Progress from "@/components/Progress";
import { useEffect, useState } from "react";
import { Colorful, ColorfulEvents } from "@/types";
import { defaultColorful } from "@/consts";
import Head from "next/head";

const dyeColors = [
  {
    name: "White",
    color: "#f0f0f0",
    max: 5376,
  },
  {
    name: "Black",
    color: "#111111",
    max: 5376,
  },
  {
    name: "Red",
    color: "#CC4C4C",
    max: 3840,
  },
  {
    name: "Yellow",
    color: "#dede6c",
    max: 3840,
  },
  {
    name: "Green",
    color: "#57A64E",
    max: 3840,
  },
  {
    name: "Blue",
    color: "#3366CC",
    max: 3840,
  },
  {
    name: "Brown",
    color: "#7F664C",
    max: 1536,
  },
];

const woolColors = [
  {
    name: "White",
    color: "#f0f0f0",
  },
  {
    name: "Black",
    color: "#111111",
  },
  {
    name: "Red",
    color: "#CC4C4C",
  },
  {
    name: "Yellow",
    color: "#dede6c",
  },
  {
    name: "Green",
    color: "#57A64E",
  },
  {
    name: "Blue",
    color: "#3366CC",
  },
  {
    name: "Brown",
    color: "#7F664C",
  },
  {
    name: "Orange",
    color: "#FF7F27",
  },
  {
    name: "Magenta",
    color: "#B24CD8",
  },
  {
    name: "Light Blue",
    color: "#6699D8",
  },
  {
    name: "Pink",
    color: "#F27FA5",
  },
  {
    name: "Lime",
    color: "#7FCC19",
  },
  {
    name: "Gray",
    color: "#4C4C4C",
  },
  {
    name: "Light Gray",
    color: "#999999",
  },
  {
    name: "Cyan",
    color: "#4C99B2",
  },
  {
    name: "Purple",
    color: "#7F3FB2",
  },
];

const ingredients = [
  {
    name: "Sand",
    color: "#E2DAA4",
  },
  {
    name: "Gravel",
    color: "#7F7F7F",
  },
  {
    name: "Glass",
    color: "#E2F0F7",
  },
  {
    name: "Terracotta",
    color: "#B24C27",
  },
];

function ProgressBarInfo({
  name,
  color,
  value,
  max,
}: {
  name: string;
  color: string;
  value: number;
  max: number;
}) {
  return (
    <div className="flex flex-col gap-1" key={color}>
      <p className="font-medium">{name}</p>
      <div className="flex flex-col gap-1">
        <Progress max={max} value={value} color={color} />
        <small
          className={`text-xs ${value / max < 0.05 ? "text-red-300" : ""}`}
        >
          {value}/{max}
        </small>
      </div>
    </div>
  );
}

const names: { [key: string]: string } = {
  start: "🆙 Shop Started",
  purchase: "💵 Item Purchased",
  cartridgeRefill: "🖨 Cartridge Refiller Used",
  jobComplete: "✔ Purchase Job Completed",
  stall: "⚠ System Stalled!!!",
  lowItems: "⚠ Low on Items",
};

export default function Home() {
  const [authorization, setAuthorization] = useState<string>("");
  const [authInput, setAuthInput] = useState<string>("");
  const [errorText, setErrorText] = useState<string>("");
  const [items, setItems] = useState<Colorful>(defaultColorful);
  const [time, setTime] = useState<string>("");

  useEffect(() => {
    setAuthorization(sessionStorage.getItem("authorization") || "");
  }, []);

  useEffect(() => {
    console.log(authorization);
    if (authorization === "") return;
    const getItems = async () => {
      const response = await fetch("/api/colorful/items", {
        method: "GET",
        headers: {
          Authorization: `Bearer ${authorization}`,
        },
      });
      const data: Colorful = await response.json();

      if (data.error == undefined) {
        setItems(data);
        setTime(new Date(data.lastUpdated).toLocaleString());
      }
    };
    getItems();
  }, [authorization]);

  return (
    <div className="p-12 flex flex-col gap-8">
      <Head>
        <title>Colorful Tracker</title>
      </Head>
      {authorization === "" ? (
        <div className="flex flex-col gap-2 items-center">
          <h1 className="text-5xl font-bold mb-2">Colorful Tracker</h1>
          <div className="inline-flex flex-col gap-1 w-auto">
            <input
              className="bg-slate-800 rounded-lg p-2 px-5"
              type="password"
              onChange={(event) => setAuthInput(event.target.value)}
            />
            <button
              className="bg-slate-500 rounded-lg p-2 font-bold"
              onClick={async () => {
                const response = await fetch("/api/colorful/items", {
                  method: "GET",
                  headers: {
                    Authorization: `Bearer ${authInput}`,
                  },
                });

                if (response.status === 200) {
                  sessionStorage.setItem("authorization", authInput);
                  setAuthorization(authInput);

                  const data: Colorful = await response.json();

                  if (data.error == undefined) {
                    setItems(data);
                    setTime(new Date(data.lastUpdated).toLocaleString());
                  }
                } else {
                  setErrorText(`${response.status} ${response.statusText}`);
                }
              }}
            >
              Log In
            </button>
          </div>
          <div className="text-red-400">{errorText}</div>
        </div>
      ) : (
        <>
          <div>
            <h1 className="text-5xl font-bold mb-2">Colorful Tracker</h1>
            <p>Tracks current item levels and recent events on colorful.kst</p>
            <p>
              <span className="font-semibold">Last Updated: </span> {time}
            </p>
          </div>

          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-bold">Ingredients</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 w-auto gap-4 gap-x-8 gap-y-2">
              {ingredients.map((ingredient, index) => (
                <ProgressBarInfo
                  name={ingredient.name}
                  color={ingredient.color}
                  value={
                    items.ingredients[
                      ingredient.name
                        .toLowerCase()
                        .split(" ")
                        .join("_") as keyof Colorful["ingredients"]
                    ]
                  }
                  max={13824}
                  key={index}
                />
              ))}
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-bold">Dyes</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 w-auto gap-4 gap-x-8 gap-y-2">
              {dyeColors.map((color, index) => (
                <ProgressBarInfo
                  name={color.name}
                  color={color.color}
                  value={
                    items.dyes[
                      color.name
                        .toLowerCase()
                        .split(" ")
                        .join(
                          "_"
                        ) as keyof Colorful["ingredients"] as keyof Colorful["dyes"]
                    ]
                  }
                  max={color.max}
                  key={index}
                />
              ))}
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-bold">Wool Colors</h2>
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 2xl:grid-cols-5 w-auto gap-4 gap-x-8 gap-y-2">
              {woolColors.map((color, index) => (
                <ProgressBarInfo
                  name={color.name}
                  color={color.color}
                  value={
                    items.wool[
                      color.name
                        .toLowerCase()
                        .split(" ")
                        .join(
                          "_"
                        ) as keyof Colorful["ingredients"] as keyof Colorful["wool"]
                    ]
                  }
                  max={1664}
                  key={index}
                />
              ))}
            </div>
          </div>

          <div className="flex flex-col gap-2">
            <h2 className="text-2xl font-bold">Events</h2>
            <div className="relative overflow-x-auto">
              <table className="w-full text-sm text-left text-slate-700">
                <thead className="text-xs uppercase bg-slate-800 text-slate-400">
                  <tr>
                    <th scope="col" className="px-6 py-3">
                      Type
                    </th>
                    <th scope="col" className="px-6 py-3">
                      Time
                    </th>
                    <th scope="col" className="px-6 py-3">
                      Information
                    </th>
                  </tr>
                </thead>
                <tbody>
                  {items.events.map((event, index) => (
                    <tr
                      key={index}
                      className="border-b bg-slate-900 border-slate-700 text-white"
                    >
                      <td className="px-6 py-3">{names[event.type]}</td>
                      <td className="px-6 py-3">
                        {new Date(event.time).toLocaleString()}
                      </td>
                      <td className="px-6 py-3">
                        {Object.keys(event.data).map((key) => (
                          <li key={key}>
                            <span className="font-medium">{key}</span>:{" "}
                            {event.data[key]}
                          </li>
                        ))}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
