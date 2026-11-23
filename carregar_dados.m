function [datas, t, T, U, nome_estacao] = carregar_dados(arquivo)
% CARREGAR_DADOS Le a planilha mensal do INMET e extrai Data, T e U.
% Em MATLAB usa readtable. Em Octave usa o pacote io e xlsread.

    if exist(arquivo, 'file') ~= 2
        error('Arquivo "%s" nao encontrado na pasta atual.', arquivo);
    end

    if exist('OCTAVE_VERSION', 'builtin') ~= 0
        [datas, T, U, nome_estacao] = ler_planilha_octave(arquivo);
    else
        [datas, T, U, nome_estacao] = ler_planilha_matlab(arquivo);
    end

    valido = ~isnan(datas);
    datas = datas(valido);
    T = T(valido);
    U = U(valido);

    if isempty(datas)
        error('A planilha nao possui datas validas.');
    end

    dv0 = datevec(datas(1));
    dv = datevec(datas);
    t = (dv(:, 1) - dv0(1)) * 12 + (dv(:, 2) - dv0(2)) + 1;
end

function [datas, T, U, nome_estacao] = ler_planilha_matlab(arquivo)
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
    idx_T = buscar_coluna(cols, {'TEMPERATURA', 'MEDIA', 'COMPENSADA'});
    idx_U = buscar_coluna(cols, {'UMIDADE', 'RELATIVA'});

    datas = datenum(tabela.(idx_data));
    T = para_double(tabela.(idx_T));
    U = para_double(tabela.(idx_U));

    try
        meta = readcell(arquivo, 'Range', 'A1:A1');
        nome_estacao = strtrim(strrep(char(meta{1}), 'Nome:', ''));
    catch
        [~, nome_estacao] = fileparts(arquivo);
    end
end

function [datas, T, U, nome_estacao] = ler_planilha_octave(arquivo)
    try
        eval('pkg load io');
    catch
        error(['O pacote io do Octave e necessario para ler arquivos XLSX. ', ...
            'Instale-o com: sudo apt install -y octave-io']);
    end

    [~, ~, bruto] = xlsread(arquivo);

    if size(bruto, 1) < 12
        error('A planilha nao possui o formato mensal esperado do INMET.');
    end

    cabecalho = bruto(11, :);
    dados = bruto(12:end, :);

    idx_data = buscar_coluna(cabecalho, {'Data', 'Medicao'});
    idx_T = buscar_coluna(cabecalho, {'TEMPERATURA', 'MEDIA', 'COMPENSADA'});
    idx_U = buscar_coluna(cabecalho, {'UMIDADE', 'RELATIVA'});

    datas = para_datenum(dados(:, idx_data));
    T = para_double(dados(:, idx_T));
    U = para_double(dados(:, idx_U));

    if ~isempty(bruto{1, 1})
        nome_estacao = strtrim(strrep(char(bruto{1, 1}), 'Nome:', ''));
    else
        [~, nome_estacao] = fileparts(arquivo);
    end
end

function idx = buscar_coluna(nomes, palavras)
    for k = 1:length(nomes)
        nome = upper(char(nomes{k}));
        encontrou_todas = true;

        for p = 1:length(palavras)
            if isempty(strfind(nome, upper(palavras{p})))
                encontrou_todas = false;
                break;
            end
        end

        if encontrou_todas
            idx = k;
            return;
        end
    end

    error('Coluna (%s) nao encontrada.', strjoin(palavras, ' '));
end

function v = para_datenum(col)
    v = NaN(length(col), 1);

    for i = 1:length(col)
        item = col{i};

        if isnumeric(item) && ~isempty(item)
            v(i) = double(item);

            % xlsread no Octave devolve datas como serial do Excel.
            if v(i) < 300000
                v(i) = v(i) + datenum(1899, 12, 30);
            end
        elseif ischar(item) || isstring(item)
            texto = strtrim(char(item));

            if ~isempty(texto) && ~strcmpi(texto, 'null')
                try
                    v(i) = datenum(texto);
                catch
                end
            end
        end
    end
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
        elseif ischar(item) || isstring(item)
            texto = strtrim(char(item));

            if ~isempty(texto) && ~strcmpi(texto, 'null')
                v(i) = str2double(strrep(texto, ',', '.'));
            end
        end
    end
end
