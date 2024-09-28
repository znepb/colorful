export default function Progress({
  value,
  max,
  className,
  classNameInner,
  color,
}: {
  value: number;
  max: number;
  className?: string;
  classNameInner?: string;
  color?: string;
}) {
  return (
    <div
      className={`h-5 w-full bg-slate-900 ${className} rounded-full p-0.5 border-solid border-2 ${
        value / max < 0.05 ? "border-red-900" : "border-slate-900"
      }`}
    >
      <div
        style={{
          width: `${value === 0 ? 0 : (value / max) * 100}%`,
          height: "100%",
          backgroundColor: color,
          backgroundImage: `repeating-linear-gradient(-45deg, #fff2 0, #fff2 8px, #0000 8px, #0000 calc(8px * 2))`,
        }}
        className={`rounded-full bg-slate-600 transition-all ${classNameInner}`}
      ></div>
    </div>
  );
}
