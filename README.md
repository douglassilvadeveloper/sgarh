## Apresentação
Trata-se de um projeto-base de aplicação web para a consolidação dos conhecimentos sobre a linguagem Elixir e o seu framework web Phoenix.

## O que é o SGARH?
SGARH é um sistema de gerenciamento de atividades de recursos humanos. Ele possui funcionalidades que facilitam o acompanhamento das atividades que estão pendentes e/ou em andamento, bem como das que foram realizadas pelos funcionários do setor de RH.

Leia abaixo o caso de uso pra conhecer a utilidade da ferramenta!

## Caso de Uso
O chefe do Setor de Recursos Humanos de uma empresa pretende gerenciar, por meio de uma aplicação web, todas as atividades do seu setor.

As atividades possuem vários tipos, como o cadastro de funcionários, o processamento da folha de pagamentos de funcionários, a avaliação de desempenho de funcionários, processamento de férias de funcionários, cadastro de homologação de atestados, demissão de funcionários e comunicações internas.

Cada atividade deve conter, em seu cadastro, o tipo de atividade, o título da atividade, a data base, a data final e a verificação se a atividade já foi encerrada ou não. Cada atividade pode se referir a um ou a mais funcionários.

Além disso, cada atividade pode ter vários estágios até a sua finalização, o que será chamado de andamento da atividade. Cada andamento deve ser composto por um usuário que deu andamento, a atividade a que se deu andamento, a data e hora do andamento e a descrição do andamento. 

Ao final do dia, a aplicação deve ser capaz de gerar um relatório contendo todas as atividades que tiveram andamento no dia e também deverá conter as demais atividades que, mesmo não tendo andamento naquele dia, continuam em aberto decorrentes dos dias anteriores.

Por fim, a aplicação deve fornecer campos de pesquisa por tipo de atividade, por atividade, por data de andamento, por usuário que deu andamento e por funcionário que foi objeto da atividade.

Obs. 1: Os usuários do sistema devem ser apenas o próprio chefe do RH e os seus auxiliares, sendo, portanto, um sistema fechado com acesso apenas para usuários logados. 

Obs. 2: O chefe do setor será o usuário administrador, com permissão ampla para atuar tanto no contexto dos usuários (criando, editando, deletando e listando os usuários) quanto nos demais contextos da aplicação. Já os auxiliares de RH serão apenas usuários comuns, que não poderão atuar no contexto dos usuários, apenas nos demais.


## Proposta inicial de modelagem do banco de dados

![modelagem](https://user-images.githubusercontent.com/105575914/171986331-b2fba728-9533-48ac-834b-ba0d9fe9bb34.png)

## Prototipagem inicial

![gif-sgarh](https://user-images.githubusercontent.com/105575914/176107050-9e767765-bab6-41b0-8fb6-aa03e0c02079.gif)


