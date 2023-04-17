import pg from "pg";
import dotenv from "dotenv";
import { abrirMenu } from "./menu.js";



dotenv.config();

const client = new pg.Pool(
    {
        connectionString: process.env.DATABASE_URL,
    }
)

client.on('error', (err, client) => {
    console.error('Unexpected error on idle client', err)
    process.exit(-1)
  })


client.connect()
.then(() => {
    abrirMenu(client);
}).catch((err) => {
    console.error("Erro ao conectar com o banco de dados: " + err)
})
