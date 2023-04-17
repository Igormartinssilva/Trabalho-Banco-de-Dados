import inquirer from 'inquirer';
import { queries } from './queries.js';

/** 
 * @param {import('pg').Client} client
*/
export function abrirMenu(client) {
    inquirer
        .prompt([
            {
                type: 'list',
                name: 'menu',
                message: 'Escolha uma opção:',
                choices: queries
            },
        ])
        .then((answers) => {
            console.log(answers);
            console.log(queries.find((query) => query.value === answers.menu));
            const query = queries.find((query) => query.value === answers.menu);
            const prompts = query.prompts;
            inquirer.prompt(prompts).then((answers) => {
                console.log(answers);
                console.log(query.order(answers));
                client.query(query.query, query.order(answers), (err, res) => {
                    if (err) {
                        console.error(err);
                    }
                    console.table(res.rows);
                    abrirMenu(client);
                });

            });
        });
}
