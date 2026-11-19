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

amp_T     = hypot(coef_T(2), coef_T(3));
amp_U     = hypot(coef_U(2), coef_U(3));
fase_T    = rad2deg(atan2(coef_T(3), coef_T(2)));
fase_U    = rad2deg(atan2(coef_U(3), coef_U(2)));
diff_fase = abs(mod(fase_T - fase_U + 180, 360) - 180);

% Erro relativo medio e tendencia linear de longo prazo (sobre residuos dessazonalizados)
err_T = mean(abs(res_T(valid_T)) ./ abs(T(valid_T))) * 100;
err_U = mean(abs(res_U(valid_U)) ./ abs(U(valid_U))) * 100;

tv = t(valid_T); rv = res_T(valid_T);
tend_T_decada = (sum((tv - mean(tv)) .* (rv - mean(rv))) / sum((tv - mean(tv)).^2)) * 120;

fprintf('=== RESULTADOS MMQ PERIODICO (FELIPE) ===\n');
fprintf('T(t) = %.4f + (%.4f)cos(wt) + (%.4f)sin(wt) | Amp=%.2f C | R2=%.4f\n', coef_T(1), coef_T(2), coef_T(3), amp_T, R2_T);
fprintf('U(t) = %.4f + (%.4f)cos(wt) + (%.4f)sin(wt) | Amp=%.2f %% | R2=%.4f\n', coef_U(1), coef_U(2), coef_U(3), amp_U, R2_U);
fprintf('Diferenca de fase T x U: %.1f graus\n', diff_fase);
fprintf('Erro Relativo Medio -> T: %.2f%% | U: %.2f%%\n', err_T, err_U);
fprintf('Tendencia T: %+.3f C/decada\n\n', tend_T_decada);
