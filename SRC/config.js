require("dotenv").config();

const db = {
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  database: process.env.DB_DATABASE,
  port: process.env.DB_PORT,
};

const info = {
  PORT: process.env.PORT,
  origin: process.env.ORIGIN,
  Version: process.env.VERSION,
  Token_key: process.env.TOKEN_KEY,
  Token_name: process.env.TOKEN_NAME,
};

module.exports = { info, db };
