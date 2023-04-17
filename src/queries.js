export const queries = [
    {
        value: 1,
        name: "Cadastrar novo usuário",
        query: "INSERT INTO users (name, cpf, email, phone) VALUES ($1, $2, $3, $4)",
        prompts: [
            {
                type: "input",
                name: "name",
                message: "Digite o nome do usuário:",
            },
            {
                type: "input",
                name: "cpf",
                message: "Digite o CPF do usuário:",
            },
            {
                type: "input",
                name: "email",
                message: "Digite o email do usuário:",
            },
            {
                type: "input",
                name: "phone",  
                message: "Digite o telefone do usuário:",
            }
        ],
        short: "Cadastrar novo usuário",
        order: (answers) => {
            return [answers.name, answers.cpf, answers.email, answers.phone];
        }
    },
    {
        value: 2,
        name: "Listar usuários",
        query: "SELECT * FROM usuarios",
        prompts: [],
        short: "Listar usuários",
        order: (answers) => {
            return [];
        }
    },
    {
        value: 3,
        name: "Todos os nomes dos clientes que deram lances em lotes com itens de uma categoria",
        query: "SELECT DISTINCT UE.id, UE.nome FROM public.usuariosexterno UE\
        JOIN public.lances L ON UE.id = L.id_cliente\
        JOIN public.itens I ON I.id_lote = L.id_lote\
        JOIN public.categoriasitens CI ON CI.id_item = I.id\
        JOIN public.categorias C ON C.id = CI.id_cat\
        WHERE C.nome = $1;",

        prompts: [
            {
                type: "input",
                name: "categoria",
                message: "Digite o nome da categoria:",
            },


        ],
        short: "Todos os nomes dos clientes que deram lances em lotes com itens de uma categoria",
        order: (a) => {
            return [a.categoria];
        }
    },
    {
        value: 4,
        name: "Contar quantos usuários distintos deram lances em itens com valor maior que um valor qualquer",
        query: "SELECT CAT.nome, count (distinct C.id) FROM public.clientes C\
        JOIN public.lances L ON C.id = L.id_cliente\
        JOIN public.itens I ON I.id_lote = L.id_lote\
        JOIN public.categoriasitens CI ON CI.id_item = I.id\
        JOIN public.categorias CAT ON CAT.id = CI.id_cat\
        WHERE L.preco >= $1\
        GROUP BY CAT.id;",

        prompts: [
            {
                type: "input",
                name: "valor",
                message: "Digite o valor minimo:",
            },


        ],
        short: "Contar quantos usuários distintos deram lances em itens com valor maior que um valor qualquer",
        order: (a) => {
            return [a.valor];
        }
    },
    {
        value: 5,
        name: "Em quantas categorias diferentes um vendendor vendeu itens",
        query: "SELECT DISTINCT UE.nome, count(DISTINCT id_cat) FROM vendedores V\
        JOIN usuariosexterno UE ON V.id = UE.id\
        JOIN itens ON id_vendedor = V.id\
        JOIN categoriasitens ON id_item = itens.id\
        WHERE id_lote IN \
            (SELECT L.id FROM lotes L JOIN itens I ON L.id = I.id_lote GROUP BY L.id HAVING count(I.id) = 1)\
        GROUP BY UE.id;",

        prompts: [
            
        ],
        short: "Em quantas categorias diferentes um vendendor vendeu itens",
        order: (a) => {
            return [];
        }
    },
    {
        value: 6,
        name: "Nome, CPFs e endereço de todos os clientes que ainda não pagaram o arremate de um lote",
        query: "SELECT UE.nome, UE.documento, C.endereco FROM usuariosexterno UE\
        JOIN clientes C ON UE.id = C.id\
        JOIN arremates ON UE.id = arremates.id_cliente\
        WHERE arremates.estado <> 'CONCLUIDO';",

        prompts: [
            
        ],
        short: "Nome, CPFs e endereço de todos os clientes que ainda não pagaram o arremate de um lote",
        order: (a) => {
            return [];
        }
    },
    {
        value: 7,
        name: "Soma dos valores de todos os arremates pagos por vendedor se o vendodor ja cadastrou uma quantiade minima de itens",
        query: "SELECT UE.nome, sum(A.valor)  fROM vendedores V\
        JOIN usuariosexterno UE ON V.id = UE.id\
        JOIN itens I ON I.id_vendedor = V.id\
        JOIN arremates A ON A.id_lote = I.id_lote\
        GROUP BY (V.id, UE.id)\
        HAVING count(I.id) >= $1;",

        prompts: [
            {
                type: "input",
                name: "quant",
                message: "Digite a quantidade minima de itens cadastrados pelo vendendor:",
            },
        ],
        short: "Soma dos valores de todos os arremates pagos por vendedor se o vendodor ja cadastrou\
        uma quantidade minima de itens",
        order: (a) => {
            return [a.quant];
        }
    },

    {
        value: 8,
        name: "Cliente que mais gastou em arremates",
        query: "SELECT UE.nome, sum(A.valor) FROM usuariosexterno UE\
        JOIN clientes C ON UE.id = C.id\
        JOIN arremates A ON A.id_cliente = C.id\
        GROUP BY (UE.id, C.id)\
        ORDER BY sum(A.valor) DESC \
        LIMIT 1;",

        prompts: [
            
        ],
        short: "Cliente que mais gastou em arremates",
        order: (a) => {
            return [];
        }
    },

    {
        value: 9,
        name: "visao: Lista de todas as categorias e a quantidade de itens em cada uma",
        query: "SELECT * FROM comprasDosClientes;",

        prompts: [
            
        ],
        short: "visao: Lista de todas as categorias e a quantidade de itens em cada uma",
        order: (a) => {
            return [];
        }
    },
    {
        value: 10,
        name: "Quantos categorias diferentes cada cliente comprou",
        query: "SELECT id_cli, CC.nome, count(C.id) FROM comprasDosClientes CC\
        JOIN categoriasitens CI ON CI.id_item = CC.id_item\
        JOIN categorias C ON C.id = CI.id_cat\
        GROUP BY (id_cli, CC.nome);",

        prompts: [
            
        ],
        short: "Quantos categorias diferentes cada cliente comprou",
        order: (a) => {
            return [];
        }
    },
    {
        value: 11,
        name: "Quantos clientes diferentes compraram itens de cada categoria",
        query: "SELECT C.nome, count(DISTINCT id_cli) FROM comprasDosClientes CC\
        JOIN categoriasitens CI ON CI.id_item = CC.id_item\
        JOIN categorias C ON C.id = CI.id_cat\
        GROUP BY (C.id, C.nome);",

        prompts: [
            
        ],
        short: "Quantos clientes diferentes compraram itens de cada categoria",
        order: (a) => {
            return [];
        }
    },
    {
        value: 12,
        name: "nome dos usuarios que SO compraram ou venderam no leilao tipo VICKERS",
        query: "SELECT UE.nome FROM usuariosexterno UE\
        JOIN clientes C ON UE.id = C.id\
        WHERE\
        NOT EXISTS (SELECT * FROM arremates A WHERE A.id_cliente = C.id AND A.id_lote IN (SELECT L.id FROM lotes L WHERE L.tipo = 'VICKREY'));",

        prompts: [
            
        ],
        short: "nome dos usuarios que SO compraram ou venderam no leilao tipo VICKERS",
        order: (a) => {
            return [];
        }
    },
    {
        value: 13,
        name: "Quem deu o maior lance em cada lote do tipo Vickers e qual foi o valor do segundo maior lance (o vencedor e o valor que ele devera pagar)",
        query: "SELECT L2.id,  UE.nome, L.preco, (SELECT L2.preco FROM lances L2 WHERE L2.id_lote = L.id_lote ORDER BY L2.preco DESC LIMIT 1 OFFSET 1) FROM lances L\
        JOIN clientes C ON C.id = L.id_cliente\
        JOIN usuariosexterno UE ON UE.id = C.id\
        JOIN lotes L2 ON L2.id = L.id_lote\
        WHERE L.id_lote IN (SELECT L.id FROM lotes L WHERE L.tipo = 'VICKREY') AND\
        L.preco = (SELECT L2.preco FROM lances L2 WHERE L2.id_lote = L.id_lote ORDER BY L2.preco DESC LIMIT 1)\
        ORDER BY L.preco DESC;",

        prompts: [
            
        ],
        short: "Quem deu o maior lance em cada lote do tipo Vickers e \
        qual foi o valor do segundo maior lance (o vencedor e o valor que ele devera pagar)",
        order: (a) => {
            return [];
        }
    },

    {
        value: 14,
        name: "todos os produtos que não sejam brinquedos que não foram pagos e que tenham valor mais que o pesquisado",
        query: "SELECT *\
        from arremates A\
        where valor>$1 and  not EXISTS\
        (SELECT *\
        from arremates\
        where estado='ESPERANDO' and id_lote IN\
                                    (SELECT id\
                                    FROM lotes\
                                    where id in(\
                                                SELECT id_lote\
                                                from itens\
                                                WHERE id in\
                                                            (SELECT id_item\
                                                             FROM categoriasitens\
                                                             WHERE id_cat =	\                                                                            (select id\
                                                                            from categorias\
                                                                            WHERE nome='Brinquedos')))));",

        prompts: [
            {
                type: "input",
                name: "val",
                message: "Digite o valor minimo:",
            },
        ],
        short: "todos os produtos que não sejam brinquedos que não foram pagos e que tenham valor mais de 1000",
        order: (a) => {
            return [a.val];
        }
    },
    {
        value: 15,
        name: "Inserir novos lances",
        query: "INSERT INTO public.lances (\
             id_cliente, id_lote, preco, \"timestamp\" ) VALUES (\
             $1, $2, $3, now());",

        prompts: [
            {
                type: "input",
                name: "id_cliente",
                message: "Digite o id_cliente:",
            },
            {
                type: "input",
                name: "id_lot",
                message: "Digite o id lote:",
            },
            {
                type: "input",
                name: "preco",
                message: "Digite o preco:",
            },
        ],
        short: "Inserir lances",
        order: (a) => {
            return [a.id_cliente,a.id_lot,a.preco];
        }
    },

]