create table users(
	id int auto_increment primary key,
    email varchar(100) not null,
    senha_hash varchar(255) not null
);

create table productType(
	id int auto_increment primary key,
    nome varchar(150) unique not null
);

create table products (
    id int auto_increment primary key,
    nome varchar(150) UNIQUE not null,
    valor_produto float not null,
    tipo_produto int not null,
    quantidade_estoque int not null,
    FOREIGN KEY (tipo_produto) REFERENCES productType(id)
);

create table paymentType(
	id int auto_increment primary key,
    tipo enum('pix', 'cartão', 'dinheiro') not null
);

create table shoppingCart(
	id int auto_increment primary key,
	id_usuario int not null,
    id_produto int not null,
    quantidade int not null,
    FOREIGN KEY (id_usuario) REFERENCES users(id),
    FOREIGN KEY (id_produto) REFERENCES products(id)
);

create table enderecos_entrega (
    id int auto_increment primary key,
	id_usuario int not null,
    endereco varchar(255) not null,
    FOREIGN KEY (id_usuario) REFERENCES users(id)
);

CREATE TABLE pedidos (
    id int auto_increment primary key,
    id_usuario int not null,
    id_tipo_pagamento int not null,
    valor_total float not null,
    data_pedido TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES users(id),
    FOREIGN KEY (id_tipo_pagamento) REFERENCES paymentType(id)
);

create table historico_pedidos (
    id int auto_increment primary key,
	id_pedido int not null,
    id_usuario int not null,
    valor_total float not null,
    data_pedido TIMESTAMP not null,
    FOREIGN KEY (id_pedido) REFERENCES pedidos(id),
    FOREIGN KEY (id_usuario) REFERENCES users(id)
);

DELIMITER $$

CREATE TRIGGER after_pedido_insert
AFTER INSERT ON pedidos
FOR EACH ROW
BEGIN
    DECLARE produto_id INT;
    DECLARE quantidade_pedido INT;

    -- Obtém o produto e quantidade do pedido
    SELECT id_produto, quantidade INTO produto_id, quantidade_pedido
    FROM detalhes_pedido
    WHERE id_pedido = NEW.id;

    -- Atualiza a quantidade disponível do produto no estoque
    UPDATE products
    SET quantidade_estoque = quantidade_estoque - quantidade_pedido
    WHERE id = produto_id;
END$$

DELIMITER ;after_pedido_insert

