const { Pool } = require("pg");
//.config tiene los parametros con la conexion de base datos
const { db } = require("./config");

const pool = new Pool({
  host: db.host,
  user: db.user,
  password: db.password,
  database: db.database,
  port: db.port,
  max: 10, // Número máximo de conexiones en el pool
  idleTimeoutMillis: 30000, // Tiempo máximo de inactividad de una conexión antes de cerrarla
  connectionTimeoutMillis: 2000, // Tiempo máximo para esperar una conexión
});
module.exports = pool;
