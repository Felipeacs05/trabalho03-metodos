# Trabalho 03 - Métodos Computacionais (UEFS / TEC 217)

**Grupo 03 — Termodinâmica Atmosférica (Relação Temperatura vs. Umidade)**

## Integrantes
- Felipe Amorim (Arquitetura `main.m` e `mmq_periodico.m`)
- Ikhlas (Pré-processamento e `estatistica_descritiva.m`)
- Lucas Guerra (Interpolação `interp_newton.m` e `interp_lagrange.m`)
- Vitor Costa (Regressão $T \times U$: `mmq_linear.m` e `mmq_polinomial.m`)

## Estrutura dos Arquivos
- `main.m`: Script principal que executa todas as etapas sequencialmente.
- `carregar_dados.m`: Leitura da planilha mensal do INMET e tratamento de valores `'null'`.
- `mmq_periodico.m`: Ajuste senoidal linearizado pelo Método dos Mínimos Quadrados.
- `Feira_de_Santana_Temperatura_Final.xlsx`: Base histórica INMET (contém Data, Temperatura e Umidade).

## Como Executar
1. Abra a pasta `Grupo3_TrabalhoNumerico` no MATLAB.
2. Execute `main` na janela de comandos.
3. Os gráficos em alta resolução (300 DPI) e o arquivo `dados_preprocessados.csv` serão gerados automaticamente.
