function [datas, t, T, U, nome_estacao] = carregar_dados(arquivo)
% CARREGAR_DADOS Le planilha mensal do INMET (.xlsx) e extrai Data, T e U.
% Pula as 10 linhas de metadados e converte 'null' em NaN.

if exist(arquivo, 'file') ~= 2
    error('Arquivo "%s" nao encontrado na pasta atual.', arquivo);
end

opts = detectImportOptions(arquivo, 'NumHeaderLines', 10);
try
    opts.VariableNamingRule = 'preserve';
catch
end
try
    opts = setvaropts(opts, opts.SelectedVariableNames(2:end), ...
        'TreatAsMissing', {'null', 'NULL', 'NA', 'NaN', ''});
catch
end

tabela = readtable(arquivo, opts);
datas = []; t = []; T = []; U = []; nome_estacao = '';
end
