function [stats_T, stats_U] = estatistica_descritiva(t, T, U)
% ESTATISTICA_DESCRITIVA Calcula estatisticas de temperatura e umidade.
% Os vetores de entrada permanecem inalterados. Cada variavel tem seus
% valores NaN removidos internamente antes dos calculos.

    if nargin ~= 3
        error('Use: estatistica_descritiva(t, T, U).');
    end

    t = t(:);
    T = T(:);
    U = U(:);

    if length(t) ~= length(T) || length(t) ~= length(U)
        error('Os vetores t, T e U devem ter o mesmo tamanho.');
    end

    stats_T = calcular_estatisticas(T, 'Temperatura media compensada', '°C');
    stats_U = calcular_estatisticas(U, 'Umidade relativa do ar', '%');

    fprintf('=== ESTATISTICA DESCRITIVA ===\n');
    imprimir_resumo(stats_T);
    imprimir_resumo(stats_U);
end

function stats = calcular_estatisticas(dados, nome, unidade)
    total = length(dados);
    validos = dados(~isnan(dados));

    if isempty(validos)
        error('%s nao possui observacoes validas.', nome);
    end

    validos_ordenados = sort(validos);
    n = length(validos);

    stats.nome = nome;
    stats.unidade = unidade;
    stats.total_registros = total;
    stats.observacoes_validas = n;
    stats.valores_ausentes = total - n;
    stats.percentual_ausente = 100 * stats.valores_ausentes / total;
    stats.media = mean(validos);
    stats.mediana = mediana_ordenada(validos_ordenados);
    stats.desvio_padrao = std(validos);
    stats.variancia = var(validos);
    stats.minimo = validos_ordenados(1);
    stats.maximo = validos_ordenados(end);
    stats.amplitude = stats.maximo - stats.minimo;
    stats.primeiro_quartil = percentil_linear(validos_ordenados, 25);
    stats.terceiro_quartil = percentil_linear(validos_ordenados, 75);
end

function m = mediana_ordenada(x)
    n = length(x);

    if mod(n, 2) == 1
        m = x((n + 1) / 2);
    else
        m = (x(n / 2) + x(n / 2 + 1)) / 2;
    end
end

function q = percentil_linear(x, p)
    n = length(x);
    posicao = 1 + (n - 1) * p / 100;
    inferior = floor(posicao);
    superior = ceil(posicao);

    if inferior == superior
        q = x(inferior);
    else
        q = x(inferior) + (posicao - inferior) * ...
            (x(superior) - x(inferior));
    end
end

function imprimir_resumo(stats)
    fprintf('%s (%s)\n', stats.nome, stats.unidade);
    fprintf('  Validos: %d de %d | Ausentes: %d (%.2f%%)\n', ...
        stats.observacoes_validas, stats.total_registros, ...
        stats.valores_ausentes, stats.percentual_ausente);
    fprintf('  Media: %.3f | Mediana: %.3f | Desvio padrao: %.3f\n', ...
        stats.media, stats.mediana, stats.desvio_padrao);
    fprintf('  Minimo: %.3f | Maximo: %.3f | Amplitude: %.3f\n\n', ...
        stats.minimo, stats.maximo, stats.amplitude);
end
