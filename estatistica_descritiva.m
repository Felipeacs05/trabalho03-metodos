function [stats_T, stats_U] = estatistica_descritiva(t, T, U)
% ESTATISTICA_DESCRITIVA Calcula estatisticas e gera tabela e histogramas.
% Os vetores de entrada permanecem inalterados. Os NaNs sao removidos
% internamente antes dos calculos e da construcao dos graficos.

    if nargin ~= 3
        error('Use: estatistica_descritiva(t, T, U).');
    end

    t = t(:);
    T = T(:);
    U = U(:);

    if length(t) ~= length(T) || length(t) ~= length(U)
        error('Os vetores t, T e U devem ter o mesmo tamanho.');
    end

    stats_T = calcular_estatisticas(T, 'Temperatura media compensada', 'C');
    stats_U = calcular_estatisticas(U, 'Umidade relativa do ar', '%');

    fprintf('=== ESTATISTICA DESCRITIVA ===\n');
    imprimir_resumo(stats_T);
    imprimir_resumo(stats_U);

    escrever_tabela(stats_T, stats_U);
    gerar_histograma(T, stats_T, 'Temperatura media compensada', ...
        'Temperatura (C)', 'histograma_temperatura.png', [0.85 0.33 0.10]);
    gerar_histograma(U, stats_U, 'Umidade relativa do ar', ...
        'Umidade relativa (%)', 'histograma_umidade.png', [0.10 0.45 0.75]);

    fprintf('Arquivos gerados: tabela_estatistica_descritiva.csv, ');
    fprintf('histograma_temperatura.png e histograma_umidade.png.\n\n');
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

function escrever_tabela(stats_T, stats_U)
    arquivo = 'tabela_estatistica_descritiva.csv';
    fid = fopen(arquivo, 'w');

    if fid == -1
        error('Nao foi possivel criar %s.', arquivo);
    end

    fprintf(fid, 'Variavel,Unidade,Total,Validos,Ausentes,Percentual_Ausente,Media,Mediana,Desvio_Padrao,Variancia,Minimo,Primeiro_Quartil,Terceiro_Quartil,Maximo,Amplitude\n');
    escrever_linha(fid, stats_T);
    escrever_linha(fid, stats_U);
    fclose(fid);
end

function escrever_linha(fid, stats)
    fprintf(fid, '%s,%s,%d,%d,%d,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n', ...
        stats.nome, stats.unidade, stats.total_registros, ...
        stats.observacoes_validas, stats.valores_ausentes, ...
        stats.percentual_ausente, stats.media, stats.mediana, ...
        stats.desvio_padrao, stats.variancia, stats.minimo, ...
        stats.primeiro_quartil, stats.terceiro_quartil, ...
        stats.maximo, stats.amplitude);
end

function gerar_histograma(dados, stats, titulo_grafico, rotulo_x, arquivo, cor)
    validos = dados(~isnan(dados));
    numero_classes = min(15, max(5, round(sqrt(length(validos)))));
    [contagens, centros] = hist(validos, numero_classes);

    fig = figure('Visible', 'off', 'Position', [100 100 900 500]);
    bar(centros, contagens, 1, 'FaceColor', cor, 'EdgeColor', [0.20 0.20 0.20]);
    hold on;

    limite_y = ylim;
    plot([stats.media stats.media], limite_y, 'r--', 'LineWidth', 1.8);
    plot([stats.mediana stats.mediana], limite_y, 'k-.', 'LineWidth', 1.8);

    title(['Distribuicao da ' titulo_grafico]);
    xlabel(rotulo_x);
    ylabel('Frequencia');
    legend('Observacoes validas', 'Media', 'Mediana', 'Location', 'best');
    grid on;

    print(fig, arquivo, '-dpng', '-r300');
    close(fig);
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
