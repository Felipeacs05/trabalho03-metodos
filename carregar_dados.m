function [datas, t, T, U, nome_estacao] = carregar_dados(arquivo)
% CARREGAR_DADOS Le planilha mensal do INMET (.xlsx) e extrai Data, T e U.

if exist(arquivo, 'file') ~= 2
    error('Arquivo "%s" nao encontrado na pasta atual.', arquivo);
end
datas = []; t = []; T = []; U = []; nome_estacao = '';
end
