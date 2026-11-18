function [datas, t, T, U, nome_estacao] = carregar_dados(arquivo)
% CARREGAR_DADOS Le planilha mensal do INMET (.xlsx) e extrai Data, T e U.
% Pula as 10 linhas de metadados, localiza colunas pelo nome e converte 'null' em NaN.

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
cols = tabela.Properties.VariableNames;

idx_data = buscar_coluna(cols, {'Data', 'Medicao'});
idx_T    = buscar_coluna(cols, {'TEMPERATURA', 'MEDIA', 'COMPENSADA'});
idx_U    = buscar_coluna(cols, {'UMIDADE', 'RELATIVA'});

datas = datenum(tabela.(idx_data));
T     = para_double(tabela.(idx_T));
U     = para_double(tabela.(idx_U));

% Remove eventuais linhas vazias no fim da planilha
valido = ~isnan(datas);
datas = datas(valido);
T     = T(valido);
U     = U(valido);
t = (1:length(datas))';
nome_estacao = '';
end

function idx = buscar_coluna(nomes, palavras)
    for k = 1:length(nomes)
        nome = upper(char(nomes{k}));
        if all(cellfun(@(p) contains(nome, upper(p)), palavras))
            idx = k;
            return;
        end
    end
    error('Coluna (%s) nao encontrada na planilha.', strjoin(palavras, ' '));
end

function v = para_double(col)
    if isnumeric(col)
        v = double(col(:));
        return;
    end
    v = NaN(length(col), 1);
    for i = 1:length(col)
        item = col{i};
        if isnumeric(item) && ~isempty(item)
            v(i) = double(item);
        elseif (ischar(item) || isstring(item)) && ~strcmpi(strtrim(char(item)), 'null')
            v(i) = str2double(char(item));
        end
    end
end
