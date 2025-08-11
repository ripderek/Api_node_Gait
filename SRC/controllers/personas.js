const pool = require("../db");
const Crear = async (req, res, next) => {
  let client;
  try {
    const { persona } = req.body;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call crearPersona($1)", [persona]);
    return res.status(200).json({ message: "Se registró una persona" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

const Editar = async (req, res, next) => {
  let client;
  try {
    const { persona } = req.body;
    const { personaid } = req.params;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call editarPersona($1,$2)", [persona, personaid]);
    return res.status(200).json({ message: "Se editó una persona" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

const Eliminar = async (req, res, next) => {
  let client;
  try {
    const { personaid } = req.params;
    client = await pool.connect(); // Obtener una conexión del pool
    await client.query("call eliminarPersona($1)", [personaid]);
    return res.status(200).json({ message: "Se eliminó una persona" });
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

const Listar = async (req, res, next) => {
  let client;
  try {
    client = await pool.connect(); // Obtener una conexión del pool
    const result = await client.query("select * from listarPersonas()");
    return res.status(200).json(result.rows);
  } catch (error) {
    console.log(error);
    return res.status(404).json({ error: error.message });
  } finally {
    if (client) client.release(); // Liberar la conexión
  }
};

module.exports = {
  Listar,
  Crear,
  Editar,
  Eliminar,
};
