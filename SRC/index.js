const express = require("express");
const cors = require("cors");
const ascii = require("./console.js");
const { info } = require("./config.js");

//Consfigurar el puerto donde se va abrir la API
const app = express();

const corsOptions = {
  credentials: true,
  origin: [info.origin],
};

//config del server
app.use(cors(corsOptions));
app.use(express.json());

//Rutas
app.use("/personas", require("./routes/personas.js"));
app.use("/muestras", require("./routes/muestras.js"));
app.use("/modelos", require("./routes/modelos.js"));
app.use("/muestras_personas", require("./routes/muestras_personas.js"));

app.listen(
  info.PORT,
  () => (
    console.log("SERVER ON PORT" + info.PORT),
    console.log("Escuchando: " + info.origin),
    console.log(info.Version)
  )
);
console.log(ascii());
