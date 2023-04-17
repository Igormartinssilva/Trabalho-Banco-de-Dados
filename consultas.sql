-- Todos os nomes dos clientes que deram lances em lotes com itens da categoria 'Livros'
SELECT DISTINCT UE.id, UE.nome FROM public.usuariosexterno UE
JOIN public.lances L ON UE.id = L.id_cliente
JOIN public.itens I ON I.id_lote = L.id_lote
JOIN public.categoriasitens CI ON CI.id_item = I.id
JOIN public.categorias C ON C.id = CI.id_cat
WHERE C.nome = 'Livros';

-- Contar quantos usuários distintos deram lances em itens com valor maior que 1000
SELECT CAT.nome, count(C.id) FROM public.clientes C
JOIN public.lances L ON C.id = L.id_cliente
JOIN public.itens I ON I.id_lote = L.id_lote
JOIN public.categoriasitens CI ON CI.id_item = I.id
JOIN public.categorias CAT ON CAT.id = CI.id_cat
WHERE L.preco >= 1000
GROUP BY CAT.id;

-- Em quantas categorias diferentes um vendendor vendeu itens
-- (considerar apenas itens vendidos em lotes com apenas um item)
-- Aparecer o nome do vendedor e a quantidade de categorias
SELECT DISTINCT UE.nome, count(DISTINCT id_cat) FROM vendedores V 
JOIN usuariosexterno UE ON V.id = UE.id
JOIN itens ON id_vendedor = V.id
JOIN categoriasitens ON id_item = itens.id
-- JOIN categorias ON categorias.id = categoriasitens.id_cat
WHERE id_lote IN 
    (SELECT L.id FROM lotes L JOIN itens I ON L.id = I.id_lote GROUP BY L.id HAVING count(I.id) = 1)
GROUP BY UE.id;

-- Nome, CPFs e endereço de todos os clientes que ainda não pagaram o arremate de um lote
SELECT UE.nome, UE.documento, C.endereco FROM usuariosexterno UE
JOIN clientes C ON UE.id = C.id
JOIN arremates ON UE.id = arremates.id_cliente
WHERE arremates.estado <> 'CONCLUIDO';



-- Soma dos valores de todos os arremates pagos por vendedor se o vendodor ja cadastradou
-- no minimo 2 itens
SELECT UE.nome, sum(A.valor)  fROM vendedores V
JOIN usuariosexterno UE ON V.id = UE.id
JOIN itens I ON I.id_vendedor = V.id
JOIN arremates A ON A.id_lote = I.id_lote
GROUP BY (V.id, UE.id)
HAVING count(I.id) >= 2;


-- 
-- Cliente que mais gastou em arremates
SELECT UE.nome, sum(A.valor) FROM usuariosexterno UE
JOIN clientes C ON UE.id = C.id
JOIN arremates A ON A.id_cliente = C.id
GROUP BY (UE.id, C.id)
ORDER BY sum(A.valor) DESC 
LIMIT 1;

-- Apagar todos os lotes que nao foram arrematados, não possuiem lances e que tenham passado da 
-- data de fim do leilao
-- DELETE FROM lotes L
SELECT * FROM lotes L
WHERE L.id NOT IN (SELECT id_lote FROM arremates)
AND L.id NOT IN (SELECT id_lote FROM lances)
AND L.fim_leilao < now();

--
-- Necessita de NOT EXISTS
-- Itens que são parte de um lote com lances do cliente id = 3 e que compartilham uma categoria com o item id = 1




-- VISAO

-- a)Lista de todas as categorias e a quantidade de itens em cada uma
-- b) Lista de Clientes com todos os seus dados e os itens que ele comprou
CREATE OR REPLACE VIEW comprasDosClientes AS 
    SELECT C.id as id_cli, I.id AS id_item, c.endereco, UE.documento, UE.nome, U.email, U.username, A.valor, A.estado, I.titulo, I.desc_detalhada FROM clientes C
    JOIN usuariosexterno UE ON C.id = UE.id
    JOIN usuarios U ON U.id = UE.id
    LEFT JOIN arremates A ON A.id_cliente = C.id
    LEFT JOIN itens I ON I.id_lote = A.id_lote;
SELECT * FROM comprasDosClientes;

-- Quantos categorias diferentes cada cliente comprou
SELECT id_cli, CC.nome, count(C.id) FROM comprasDosClientes CC
JOIN categoriasitens CI ON CI.id_item = CC.id_item
JOIN categorias C ON C.id = CI.id_cat
GROUP BY (id_cli, CC.nome);

-- Quantos clientes diferentes compraram itens de cada categoria
SELECT C.nome, count(DISTINCT id_cli) FROM comprasDosClientes CC
JOIN categoriasitens CI ON CI.id_item = CC.id_item
JOIN categorias C ON C.id = CI.id_cat
GROUP BY (C.id, C.nome);

-- PROCEDIMENTO ARMAZENADO E TRIGGER

CREATE OR REPLACE FUNCTION onInsertLance() 
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT * FROM lotes WHERE id = NEW.id_lote AND fim_leilao < now()) THEN
        RAISE EXCEPTION 'Leilao ja encerrado';
    END IF;
    IF EXISTS (SELECT * FROM arremates WHERE id_lote = NEW.id_lote) THEN
        RAISE EXCEPTION 'Lote ja arrematado';
    END IF;
    IF NEW.preco < (SELECT L.preco_inicial FROM lotes L WHERE L.id = NEW.id_lote) THEN
        RAISE EXCEPTION 'Lance menor que o preco inicial';
    END IF;
    -- Se o leilao for ingles
    IF EXISTS (SELECT * FROM lotes WHERE id = NEW.id_lote AND tipo = 'INGLES') THEN
        IF NEW.preco < (SELECT preco FROM lances WHERE id_lote = NEW.id_lote ORDER BY preco DESC LIMIT 1) THEN
            RAISE EXCEPTION 'Lance menor que o ultimo';
        END IF;


        -- Atualiza o horario pra 1 minuto a mais do que o horario do lance
        UPDATE lotes SET fim_leilao = (SELECT GREATEST(fim_leilao, now() + interval '1 minute') FROM lotes WHERE id = NEW.id_lote) WHERE id = NEW.id_lote;

    ELSE -- Se o leilao for Vickers
        -- Usuario nao pode dar 2 lances
        IF EXISTS (SELECT * FROM lances L WHERE L.id_lote = NEW.id_lote AND L.id_cliente = NEW.id_cliente) THEN
            RAISE NOTICE 'Usuario ja deu lance no lote %', NEW.id_lote;
            RAISE NOTICE '%', (SELECT count(L.id) FROM lances L WHERE L.id_lote = NEW.id_lote AND L.id_cliente = NEW.id_cliente);
            RAISE EXCEPTION 'Usuario ja deu lance';
        END IF;

    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER onInsertLanceTrigger BEFORE INSERT ON lances FOR EACH ROW EXECUTE PROCEDURE onInsertLance();

INSERT INTO public.lances (
id, id_cliente, id_lote, preco, "timestamp") VALUES (
51, 5, 21, 7210.15, now());

INSERT INTO public.lances (
id, id_cliente, id_lote, preco, "timestamp") VALUES (
53, 5, 22, 3210.15, now());


-- Nome do cliente que mais deu lances em cada categoria


-- nome dos usuarios que SO compraram ou venderam no leilao tipo VICKERS
SELECT UE.nome FROM usuariosexterno UE
JOIN clientes C ON UE.id = C.id
WHERE
NOT EXISTS (SELECT * FROM arremates A WHERE A.id_cliente = C.id AND A.id_lote IN (SELECT L.id FROM lotes L WHERE L.tipo = 'VICKREY'));

-- Quem deu o maior lance em cada lote do tipo Vickers e 
-- qual foi o valor do segundo maior lance (o vencedor e o valor que ele devera pagar)
SELECT L2.id,  UE.nome, L.preco, (SELECT L2.preco FROM lances L2 WHERE L2.id_lote = L.id_lote ORDER BY L2.preco DESC LIMIT 1 OFFSET 1) FROM lances L
JOIN clientes C ON C.id = L.id_cliente
JOIN usuariosexterno UE ON UE.id = C.id
JOIN lotes L2 ON L2.id = L.id_lote
WHERE L.id_lote IN (SELECT L.id FROM lotes L WHERE L.tipo = 'VICKREY') AND
L.preco = (SELECT L2.preco FROM lances L2 WHERE L2.id_lote = L.id_lote ORDER BY L2.preco DESC LIMIT 1)
ORDER BY L.preco DESC;




--todos os produtos que não sejam brinquedos que não foram pagos e que tenham valor mais de 1000

SELECT *
from arremates A
where valor>1000 and  not EXISTS
--daqui para baixo ve se tem brinquedos que não foram pagos
(SELECT *
from arremates
where estado='ESPERANDO' and id_lote IN
							(SELECT id
							FROM lotes
							where id in(
										SELECT id_lote
										from itens
										WHERE id in
													(SELECT id_item
													 FROM categoriasitens
													 WHERE id_cat =					
             													   (select id
																	from categorias
																	WHERE nome='Brinquedos')))));