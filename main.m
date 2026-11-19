%% TRABALHO 03 - METODOS COMPUTACIONAIS (UEFS)
% Grupo 03: Termodinamica Atmosferica (Temperatura vs. Umidade)
% Integrantes: Felipe Amorim, Ikhlas, Lucas Guerra, Vitor Costa

clear; clc; close all;

%% 1. CARREGAMENTO DOS DADOS (TEMPERATURA + UMIDADE)
% Esta planilha completa do INMET contem Data, Temperatura Media e Umidade Relativa juntas.
arquivo_dados = 'Feira_de_Santana_Temperatura_Final.xlsx';

[datas, t, T, U, cidade] = carregar_dados(arquivo_dados);

valid_T  = ~isnan(T);
valid_U  = ~isnan(U);
valid_TU = valid_T & valid_U;
N = length(t);

fprintf('=== GRUPO 03 - %s (%s a %s) ===\n', ...
    cidade, datestr(datas(1), 'yyyy-mm'), datestr(datas(end), 'yyyy-mm'));
fprintf('Meses: %d | T validos: %d | U validos: %d | Pares T&U: %d\n\n', ...
    N, sum(valid_T), sum(valid_U), sum(valid_TU));

% Salva tabela limpa com os dados pre-processados (exigido na entrega)
tabela_prep = table(t, cellstr(datestr(datas, 'yyyy-mm-dd')), T, U, ...
    'VariableNames', {'Tempo_t', 'Data_Medicao', 'Temperatura_C', 'Umidade_Pct'});
writetable(tabela_prep, 'dados_preprocessados.csv');

%% 2. ESTATISTICA DESCRITIVA (IKHLAS -> estatistica_descritiva.m)
if exist('estatistica_descritiva', 'file') == 2
    [stats_T, stats_U] = estatistica_descritiva(t, T, U);
else
    fprintf('[Aguardando Ikhlas] estatistica_descritiva.m ainda nao esta na pasta.\n');
    fprintf('  Resumo rapido -> T_media = %.2f C | U_media = %.2f %%\n\n', ...
        mean(T(valid_T)), mean(U(valid_U)));
end

%% 4. MODELAGEM DE CICLOS - MMQ PERIODICO (FELIPE -> mmq_periodico.m)
P = 12; % Ciclo anual (12 meses)
[coef_T, T_ajust, res_T, R2_T, Syx_T] = mmq_periodico(t, T, P);
[coef_U, U_ajust, res_U, R2_U, Syx_U] = mmq_periodico(t, U, P);

fprintf('T(t) R2=%.4f | U(t) R2=%.4f\n', R2_T, R2_U);
