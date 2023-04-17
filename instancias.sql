
DROP TABLE IF EXISTS Usuarios CASCADE;

DROP TABLE IF EXISTS UsuariosExterno CASCADE;

DROP TABLE IF EXISTS Clientes CASCADE;

DROP TABLE IF EXISTS Vendedores CASCADE;

DROP TABLE IF EXISTS Administradores CASCADE;

DROP TABLE IF EXISTS Categorias CASCADE;

DROP TYPE IF EXISTS leilao_t CASCADE;

DROP TABLE IF EXISTS Lotes CASCADE;

DROP TABLE IF EXISTS Itens CASCADE;

DROP TABLE IF EXISTS CategoriasItens CASCADE;

DROP TABLE IF EXISTS Fotos CASCADE;


DROP TABLE IF EXISTS Lances CASCADE;

DROP TYPE IF EXISTS estado_pgmto_t CASCADE;

DROP TABLE IF EXISTS Arremates CASCADE;


-- Criar tabelas


CREATE TABLE Usuarios (
    id serial not null,
    username varchar(100) not null UNIQUE,
    senha char(61) not null,
    email varchar(100) not null unique,
    PRIMARY KEY(id)
);

CREATE TABLE UsuariosExterno (
    id int not null PRIMARY KEY,
    documento char(14) not null,
    nome varchar not null,
    FOREIGN KEY (id) references Usuarios
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT documento_unico UNIQUE (documento)
);

CREATE TABLE  Clientes (
    id int not null PRIMARY KEY,
    endereco varchar(128) not null,

    FOREIGN KEY (id) references UsuariosExterno
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Vendedores (
    id int not null PRIMARY KEY,
    FOREIGN KEY (id) references Usuarios
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Administradores(
    id int not null PRIMARY KEY,
    FOREIGN KEY (id) references Usuarios
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Categorias(
    id serial not null PRIMARY key,
    nome varchar(50) not null
);

CREATE type leilao_t as ENUM('INGLES','VICKREY');

CREATE TABLE Lotes (
    id serial not null PRIMARY KEY,
    preco_inicial NUMERIC(15,2) not null,
    inicio_leilao timestamp not null,
    fim_leilao timestamp not null,
    tipo leilao_t not null
);

CREATE TABLE Itens (
    id serial not null PRIMARY KEY,
    titulo varchar(256) NOT NULL, 
    desc_detalhada varchar not null,
    id_vendedor int not null,
    id_lote int not null,
    FOREIGN KEY (id_vendedor) references Vendedores
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (id_lote) references Lotes
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE CategoriasItens (
    id serial not null PRIMARY KEY,
    id_cat INT not NULL,
    id_item INT NOT NULL,
    UNIQUE (id_cat, id_item),
    foreign key (id_cat) references Categorias
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    foreign key (id_item) references Itens
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE Fotos (
    id serial not null PRIMARY KEY,
    url varchar not null,
    id_item int not null,
    foreign key (id_item) references Itens
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


CREATE TABLE Lances (
    id serial not null PRIMARY KEY,
    id_cliente int not null, 
    id_lote int not null,
    preco numeric(15,2) not null,
    timestamp timestamp not null,
    foreign key (id_cliente) references Clientes
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    foreign key (id_lote) references Lotes
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT lance_tem_que_ser_unico UNIQUE (id_cliente, id_lote, timestamp),
    CONSTRAINT preco_nao_pode_ser_negativo CHECK (preco >= 0),
    CONSTRAINT lote_so_pode_ter_um_lance_por_valor UNIQUE(preco, id_lote)
);

CREATE type estado_pgmto_t as enum('ESPERANDO', 'PROCESSANDO', 'VENCIDO', 'CANCELADO', 'CONCLUIDO');

CREATE TABLE Arremates (
    id serial not null PRIMARY KEY,
    data_criacao timestamp not null,
    data_vencimento timestamp not null,
    data_pgmto timestamp, -- pode ser nulo
    valor NUMERIC (15, 2) not null,
    estado estado_pgmto_t not null,
    id_cliente int not null, 
    id_lote int not null,
    CONSTRAINT arremate_tem_que_ser_unico UNIQUE (id_lote),
    CONSTRAINT arremate_pago_tem_que_ter_data_pgmto CHECK (estado != 'CONCLUIDO' OR data_pgmto IS NOT NULL),
    CONSTRAINT valor_nao_pode_ser_negativo CHECK (valor >= 0),
    CONSTRAINT data_vencimento_maior_que_criacao CHECK (data_vencimento > data_criacao),
    CONSTRAINT data_pgmto_anterior_ou_igual_vencimento CHECK (data_pgmto <= data_vencimento),
    CONSTRAINT data_pgmto_posterior_ou_igual_criacao CHECK (data_pgmto >= data_criacao),

    foreign key (id_cliente) references Clientes
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    foreign key (id_lote) references Lotes
        ON DELETE CASCADE
        ON UPDATE CASCADE
);


--
-- Criar instancias de teste
-- 

INSERT INTO usuarios (id, username, senha, email) VALUES (1, 'admin', 'admin', 'admin@localhost');
INSERT INTO administradores (id) VALUES (1);


INSERT INTO usuarios (id, username, senha, email) VALUES (2, 'vendedor', 'vendedor', 'vendedor@localhost');
INSERT INTO UsuariosExterno (id, documento, nome) VALUES (2, '12345678901', 'Vendedor');
INSERT INTO vendedores (id) VALUES (2);

INSERT INTO usuarios VALUES (3, 'comprador', 'comprador', 'comprador@localhost');
INSERT INTO UsuariosExterno (id, documento, nome) VALUES (3, '12345678902', 'Comprador');
INSERT INTO clientes (id, endereco) VALUES (3, 'Rua do Comprador, 123');

INSERT INTO usuarios VALUES (4, 'comprador2', 'comprador2', 'comprador2@localhost');
INSERT INTO UsuariosExterno (id, documento, nome) VALUES (4, '12345678903', 'Comprador2');
INSERT INTO clientes (id, endereco) VALUES (4, 'Rua do Comprador2, 123');

INSERT INTO usuarios VALUES (5, 'comprador3', 'comprador3', 'comprador3@localhost');
INSERT INTO UsuariosExterno (id, documento, nome) VALUES (5, '12345678904', 'Comprador3');
INSERT INTO clientes (id, endereco) VALUES (5, 'Rua do Comprador3, 123');

INSERT INTO categorias VALUES (1, 'Categoria 1');

INSERT INTO lotes VALUES (1, 100, '2018-01-01 00:00:00', '2018-01-01 00:00:00', 'INGLES');
INSERT INTO itens VALUES (1, 'Item 1', 'Descricao detalhada do item 1', 2, 1);
INSERT INTO fotos VALUES (1, 'http://www.google.com', 1);
INSERT INTO categoriasitens VALUES (1, 1, 1);

INSERT INTO lances VALUES (1, 3, 1, 100, '2018-01-01 00:00:00');
INSERT INTO lances VALUES (2, 4, 1, 200, '2018-01-01 00:00:01');
INSERT INTO lances VALUES (3, 5, 1, 300, '2018-01-01 00:00:02');
INSERT INTO lances VALUES (4, 3, 1, 1000, '2018-01-01 00:00:03');

INSERT INTO arremates VALUES (1, '2018-01-01 00:00:30', '2018-01-03 00:20:30', '2018-01-01 00:10:00', 1000, 'CONCLUIDO', 3, 1);

INSERT INTO Usuarios (id, username, senha, email) VALUES
(10, 'user10', 'senha10', 'user10@example.com'),
(11, 'user11', 'senha11', 'user11@example.com'),
(12, 'user12', 'senha12', 'user12@example.com'),
(13, 'user13', 'senha13', 'user13@example.com'),
(14, 'user14', 'senha14', 'user14@example.com');

INSERT INTO UsuariosExterno (id, documento, nome) VALUES
(10, '111.111.111-11', 'João Silva'),
(11, '222.222.222-22', 'Maria Souza'),
(12, '333.333.333-33', 'Pedro Santos'),
(13, '444.444.444-44', 'Ana Oliveira'),
(14, '555.555.555-55', 'Lucas Costa');

INSERT INTO Clientes (id, endereco) VALUES
(10, 'Rua A, 123 - Bairro X - Cidade Y - Estado Z'),
(11, 'Rua B, 456 - Bairro W - Cidade V - Estado U'),
(12, 'Rua C, 789 - Bairro T - Cidade S - Estado R'),
(13, 'Rua D, 012 - Bairro Q - Cidade P - Estado O'),
(14, 'Rua E, 345 - Bairro N - Cidade M - Estado L');

INSERT INTO Vendedores (id) VALUES
(10),
(11),
(12),
(13),
(14);

INSERT INTO Administradores (id) VALUES
(10),
(11),
(12);

INSERT INTO Categorias (id, nome) VALUES
(11, 'Eletrônicos'),
(12, 'Móveis'),
(13, 'Roupas'),
(14, 'Livros'),
(15, 'Brinquedos');

INSERT INTO Lotes (id, preco_inicial, inicio_leilao, fim_leilao, tipo) VALUES
(10, 1000.00, '2023-04-01 14:00:00', '2023-04-08 14:00:00', 'INGLES'),
(11, 500.00, '2023-04-05 10:00:00', '2023-04-07 18:00:00', 'VICKREY'),
(12, 200.00, '2023-04-03 08:00:00', '2023-04-06 20:00:00', 'INGLES'),
(13, 1500.00, '2023-04-02 12:00:00', '2023-04-05 12:00:00', 'VICKREY'),
(14, 800.00, '2023-04-04 16:00:00', '2023-04-09 16:00:00', 'INGLES');

INSERT INTO Itens (id, titulo, desc_detalhada, id_vendedor, id_lote) VALUES
(10, 'iPhone 13 Pro Max', 'Último modelo de iPhone com tela de 6,7 polegadas e câmera tripla', 10, 10),
(11, 'Sofá de couro', 'Sofá grande de couro marrom, em ótimo estado', 11, 11),
(12, 'Camisa social', 'Camisa social de algodão, tamanho M', 12, 12),
(13, 'Livro de história', 'Livro de história do Brasil, usado, mas em bom estado', 13, 13),
(14, 'Boneca Barbie', 'Boneca Barbie com roupas e acessórios', 14, 14);

INSERT INTO CategoriasItens (id, id_cat, id_item) VALUES
(10,11, 10),
(11,12, 11),
(12,13, 12),
(13,14, 13),
(14,15, 14);

INSERT INTO Fotos (id, url, id_item) VALUES
(10, 'https://exemplo.com/iphone.jpg', 10),
(11, 'https://exemplo.com/sofa.jpg', 11),
(12, 'https://exemplo.com/camisa.jpg', 12),
(13, 'https://exemplo.com/livro.jpg', 13),
(14, 'https://exemplo.com/boneca.jpg', 14);

INSERT INTO Lances (id, id_cliente, id_lote, preco, timestamp) VALUES
(10, 10, 10, 5000.00, '2023-03-22 10:00:00'),
(11, 11, 11, 1500.00, '2023-03-22 10:30:00'),
(12, 12, 12, 100.00, '2023-03-22 11:00:00'),
(13, 13, 13, 50.00, '2023-03-22 11:30:00'),
(14, 14, 14, 200.00, '2023-03-22 12:00:00'),
(15, 11, 10, 5100.00, '2023-03-22 12:30:00'),
(16, 12, 11, 1600.00, '2023-03-22 13:00:00'),
(17, 13, 12, 150.00, '2023-03-22 13:30:00'),
(18, 14, 13, 60.00, '2023-03-22 14:00:00'),
(19, 10, 14, 250.00, '2023-03-22 14:30:00'),
(20, 11, 10, 5200.00, '2023-03-22 15:00:00'),
(21, 12, 11, 1700.00, '2023-03-22 15:30:00'),
(22, 13, 12, 160.00, '2023-03-22 16:00:00'),
(23, 14, 13, 70.00, '2023-03-22 16:30:00'),
(24, 10, 14, 260.00, '2023-03-22 17:00:00'),
(25, 11, 10, 5300.00, '2023-03-22 17:30:00'),
(26, 12, 11, 1800.00, '2023-03-22 18:00:00'),
(27, 13, 12, 170.00, '2023-03-22 18:30:00'),
(28, 14, 13, 80.00, '2023-03-22 19:00:00'),
(29, 10, 14, 270.00, '2023-03-22 19:30:00'),
(30, 11, 10, 5400.00, '2023-03-22 20:00:00'),
(31, 12, 11, 1900.00, '2023-03-22 20:30:00'),
(32, 13, 12, 180.00, '2023-03-22 21:00:00');


INSERT INTO Arremates (id, data_criacao, data_vencimento, data_pgmto, valor, estado, id_cliente, id_lote) VALUES
(10, '2023-03-22 10:00:00', '2023-03-24 10:00:00', '2023-03-22 10:00:00', 5000.00, 'CONCLUIDO', 10, 10),
(11, '2023-03-22 10:30:00', '2023-03-24 10:30:00', NULL, 1500.00, 'ESPERANDO', 11, 11),
(12, '2023-03-22 11:00:00', '2023-03-24 11:00:00', '2023-03-22 11:00:00', 100.00, 'CONCLUIDO', 12, 12),
(13, '2023-03-22 11:30:00', '2023-03-24 11:30:00', '2023-03-22 11:30:00', 50.00, 'CONCLUIDO', 13, 13),
(14, '2023-03-22 12:00:00', '2023-03-24 12:00:00', '2023-03-24 11:20:00', 200.00, 'CONCLUIDO', 14, 14);


INSERT INTO Lotes (id, preco_inicial, inicio_leilao, fim_leilao, tipo) VALUES
(15, 5000.00, '2023-04-01 10:00:00', '2023-04-04 10:00:00', 'VICKREY'),
(16, 1500.00, '2023-04-01 10:30:00', '2023-04-04 10:30:00', 'VICKREY'),
(17, 1600.00, '2023-04-01 11:00:00', '2023-04-04 11:00:00', 'VICKREY'),
(18, 1700.00, '2023-04-01 11:30:00', '2023-04-04 11:30:00', 'VICKREY'),
(19, 1800.00, '2023-04-01 12:00:00', '2023-04-04 12:00:00', 'VICKREY');

INSERT INTO Itens (id, titulo, desc_detalhada, id_lote, id_vendedor) VALUES
(15, 'iPhone 6', 'iPhone 6, usado, mas em bom estado', 15, 11),
(16, 'Sansung Galaxy S7', 'Sansung Galaxy S7, usado, mas em bom estado', 16, 11),
(17, 'Sansung Galaxy S8', 'Sansung Galaxy S8, usado, mas em bom estado', 17, 11),
(18, 'Sansung Galaxy S9', 'Sansung Galaxy S9, usado, mas em bom estado', 18, 11),
(19, 'Sansung Galaxy S10', 'Sansung Galaxy S10, usado, mas em bom estado', 19, 11);

INSERT INTO categoriasitens (id, id_cat, id_item) VALUES
(15, 11, 15),
(16, 11, 16),
(17, 11, 17),
(18, 11, 18),
(19, 11, 19);

INSERT INTO lances (id, id_cliente, id_lote, preco, timestamp) VALUES
(33, 10, 15, 5000.00, '2023-03-22 10:00:00'),
(34, 11, 15, 5100.00, '2023-03-22 10:30:00'),
(35, 12, 15, 5200.00, '2023-03-22 11:00:00'),
(36, 13, 15, 5300.00, '2023-03-22 11:30:00'),
(37, 14, 15, 5400.00, '2023-03-22 12:00:00'),
(38, 10, 15, 5500.00, '2023-03-22 12:30:00'),
(39, 11, 15, 5600.00, '2023-03-22 13:00:00'),
(40, 12, 15, 5700.00, '2023-03-22 13:30:00'),
(41, 13, 15, 5800.00, '2023-03-22 14:00:00'),
(42, 14, 15, 5900.00, '2023-03-22 14:30:00'),
(43, 10, 15, 6000.00, '2023-03-22 15:00:00'),
(44, 11, 15, 6100.00, '2023-03-22 15:30:00'),
(45, 12, 15, 6200.00, '2023-03-22 16:00:00'),
(46, 13, 15, 6300.00, '2023-03-22 16:30:00'),
(47, 14, 15, 6400.00, '2023-03-22 17:00:00'),
(48, 10, 15, 6500.00, '2023-03-22 17:30:00'),
(49, 11, 15, 6600.00, '2023-03-22 18:00:00');

INSERT INTO arremates (id, data_criacao, data_vencimento, data_pgmto, valor, estado, id_cliente, id_lote) VALUES
(15, '2023-04-01 10:00:00', '2023-04-04 10:00:00', '2023-04-01 10:00:00', 5000.00, 'CONCLUIDO', 10, 15);

-- Cria lote sem lances que ja passou do prazo de vencimento

INSERT INTO Lotes (id, preco_inicial, inicio_leilao, fim_leilao, tipo) VALUES
(20, 5000.00, '2023-03-01 10:00:00', '2023-03-04 10:00:00', 'VICKREY');

-- Cria lote sem lances que ainda nao chegou no prazo de vencimento

INSERT INTO Lotes (id, preco_inicial, inicio_leilao, fim_leilao, tipo) VALUES
(21, 5000.00, '2023-04-01 10:00:00', '2023-06-04 10:00:00', 'VICKREY'),
(22, 3100.87, '2023-04-01 10:00:00', '2023-06-04 10:00:00', 'INGLES');




INSERT INTO Lotes (id, preco_inicial, inicio_leilao, fim_leilao, tipo) VALUES
(54, 5000.00, '2023-04-01 10:00:00', '2023-04-04 10:00:00', 'VICKREY'),
(50, 5000.00, '2023-04-01 10:00:00', '2023-04-04 10:00:00', 'VICKREY'),
(52, 5000.00, '2023-04-01 10:00:00', '2023-04-04 10:00:00', 'VICKREY');

INSERT INTO Itens (id, titulo, desc_detalhada, id_vendedor, id_lote) VALUES
(51, 'Boneco Max Steall', 'Boneca max com roupas e acessórios', 14, 50),
(53, 'notebook', 'notebook com roupas e acessórios', 14, 52),
(52, 'Boneco T-Rex', 'Boneca dinossauro com roupas e acessórios', 14, 54);

INSERT INTO CategoriasItens (id, id_cat, id_item) VALUES
(167,15, 51),
(111,11, 53),
(60,15, 52);

INSERT INTO Arremates (id, data_criacao, data_vencimento, data_pgmto, valor, estado, id_cliente, id_lote) VALUES
(20, '2023-03-22 10:30:00', '2023-03-24 10:30:00', '2023-03-24 10:00:00', 1500.00, 'CONCLUIDO', 14, 50),
(21, '2023-03-22 10:30:00', '2023-03-24 10:30:00', '2023-03-22 11:30:00', 1500.00, 'CONCLUIDO', 14, 54),
(23, '2023-03-22 10:30:00', '2023-03-24 10:30:00', NULL, 1500.00, 'ESPERANDO', 14, 52);
