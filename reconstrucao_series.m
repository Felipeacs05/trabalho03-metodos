function [T_reconst, U_reconst, resultados] = reconstrucao_series(t, T, U, datas, pasta_saida, gerar_figuras)
% RECONSTRUCAO_SERIES Reconstrucao e validacao de series climaticas.
% Reconstrucao local, validacao por ocultacao e estudo de grau elevado.
% Apenas dados originais servem de apoio: estimativas nao alimentam outras.
if nargin < 5, pasta_saida = 'resultados_interpolacao'; end
if nargin < 6, gerar_figuras = true; end
t = t(:); T = T(:); U = U(:); datas = datas(:);
if numel(t) ~= numel(T) || numel(t) ~= numel(U) || numel(t) ~= numel(datas) || ...
        numel(t) < 5 || any(~isfinite(t)) || any(diff(t) <= 0)
    error('reconstrucao:entrada', 'Use pelo menos 5 meses, vetores alinhados e tempo finito crescente.');
end
if any(isinf(T)) || any(isinf(U))
    error('reconstrucao:entrada', 'Falhas devem ser NaN, e nao Inf.');
end
if ~exist(pasta_saida, 'dir'), mkdir(pasta_saida); end
series = {T, U}; nomes = {'Temperatura', 'Umidade'};
unidades = {'C', '%'}; reconstruidas = series;
linhas = cell(0,10); resumo = cell(0,8); preenchidas = zeros(2,1);
fprintf('\n==== RECONSTRUCAO POR INTERPOLACAO (GRUPO 3) ====\n');
for s = 1:2
    y = series{s}; yr = y;
    % Usa somente os meses t-2,t-1,t+1,t+2: grau 3, sem extrapolacao.
    for k = 3:numel(t)-2
        viz = [k-2 k-1 k+1 k+2];
        local_ok = all(t(viz)' == t(k) + [-2 -1 1 2]) && all(isfinite(y(viz)));
        if ~local_ok, continue; end
        pn = interp_newton(t(viz), y(viz), t(k));
        pl = interp_lagrange(t(viz), y(viz), t(k));
        if isnan(y(k))
            yr(k) = pn;
            preenchidas(s) = preenchidas(s) + 1;
        else
            % O valor real ocultado NAO participa dos quatro nos de apoio.
            en = abs(pn-y(k)); el = abs(pl-y(k));
            rn = NaN; rl = NaN;
            if y(k) ~= 0
                rn = 100*en/abs(y(k)); rl = 100*el/abs(y(k));
            end
            linhas(end+1,:) = {nomes{s}, t(k), datestr(datas(k),'yyyy-mm'), ...
                y(k), pn, pl, en, el, rn, rl}; %#ok<AGROW>
        end
    end
    reconstruidas{s} = yr;
    fprintf('%s: %d falhas originais; %d preenchidas; %d mantidas como NaN.\n', ...
        nomes{s}, sum(isnan(y)), preenchidas(s), sum(isnan(yr)));
    % Janela de 25 meses consecutivos observados; oculta o ponto central.
    % 24 nos -> grau <=23; o mesmo alvo e comparado com quatro nos locais.
    inicio = [];
    for k = 1:numel(t)-24
        jan = k:k+24;
        if all(isfinite(y(jan))) && all(diff(t(jan)) == 1)
            inicio = k; break;
        end
    end
    if isempty(inicio)
        fprintf('Sem janela completa de 25 meses para %s; estudo global omitido.\n', nomes{s});
        continue;
    end
    jan = inicio:inicio+24; centro = inicio+12;
    nos = jan(jan ~= centro); viz = centro + [-2 -1 1 2];
    grade = linspace(t(jan(1)), t(jan(end)), 2401);
    gn = interp_newton(t(nos), y(nos), grade);
    gl = interp_lagrange(t(nos), y(nos), grade);
    grade_local = linspace(t(centro-2), t(centro+2), 401);
    ln = interp_newton(t(viz), y(viz), grade_local);
    plocal = interp_newton(t(viz), y(viz), t(centro));
    pglobal = interp_newton(t(nos), y(nos), t(centro));
    excesso = max([0, max(gn)-max(y(nos)), min(y(nos))-min(gn)]);
    erro_nos = max(abs(interp_newton(t(nos),y(nos),t(nos))-y(nos)));
    resumo(end+1,:) = {nomes{s}, t(centro), y(centro), plocal, pglobal, ...
        excesso, max(abs(gn-gl)), erro_nos}; %#ok<AGROW>
    if gerar_figuras
    fig = figure('Visible','off','Position',[100 100 1100 720]);
    subplot(2,1,1);
    plot(grade,gn,'r-','LineWidth',1.3); hold on;
    plot(grade,gl,'b--','LineWidth',1);
    plot(t(nos),y(nos),'ko','MarkerFaceColor','k','MarkerSize',4);
    plot(t(centro),y(centro),'gs','MarkerFaceColor','g','MarkerSize',7);
    title(sprintf('%s: polinomio global (24 nos, grau ate 23)',nomes{s}));
    xlabel('Tempo (meses)'); ylabel(unidades{s}); grid on;
    legend('Newton global','Lagrange global','Nos observados','Real ocultado','Location','best');
    subplot(2,1,2);
    plot(grade_local,ln,'m-','LineWidth',1.8); hold on;
    plot(t(viz),y(viz),'ko','MarkerFaceColor','k');
    plot(t(centro),y(centro),'gs','MarkerFaceColor','g','MarkerSize',8);
    plot(t(centro),plocal,'rx','LineWidth',2,'MarkerSize',10);
    plot(t(centro),pglobal,'b+','LineWidth',2,'MarkerSize',10);
    title(sprintf('Falha simulada em %s: interpolacao local de grau 3',datestr(datas(centro),'yyyy-mm')));
    xlabel('Tempo (meses)'); ylabel(unidades{s}); grid on;
    legend('Newton local (Lagrange coincide)','4 nos locais','Real ocultado', ...
        'Estimativa local','Estimativa global','Location','best');
    print(fig,fullfile(pasta_saida,['fig_interpolacao_' lower(nomes{s}) '.png']),'-dpng','-r300');
    close(fig);
    end
    fprintf('%s (janela %s a %s): excesso global fora da faixa dos nos = %.6g %s.\n', ...
        nomes{s}, datestr(datas(jan(1)),'yyyy-mm'),datestr(datas(jan(end)),'yyyy-mm'),excesso,unidades{s});
end
T_reconst = reconstruidas{1}; U_reconst = reconstruidas{2};
validacao = cell2table(linhas,'VariableNames',{'Variavel','Tempo','Mes','Real', ...
    'Newton','Lagrange','ErroAbsNewton','ErroAbsLagrange','ErroRelNewtonPct','ErroRelLagrangePct'});
grau_alto = cell2table(resumo,'VariableNames',{'Variavel','TempoOculto','Real', ...
    'LocalGrau3','GlobalGrau23','ExcessoGlobalFaixaNos','DiferencaNewtonLagrange','ErroMaxNosNewton'});
writetable(validacao,fullfile(pasta_saida,'validacao_interpolacao.csv'));
writetable(grau_alto,fullfile(pasta_saida,'comparacao_grau_alto.csv'));
tabela = table(t,cellstr(datestr(datas,'yyyy-mm')),T,U,T_reconst,U_reconst, ...
    isnan(T)&isfinite(T_reconst),isnan(U)&isfinite(U_reconst), ...
    'VariableNames',{'Tempo','Mes','T_Original','U_Original','T_Reconstruida', ...
    'U_Reconstruida','T_Preenchida','U_Preenchida'});
writetable(tabela,fullfile(pasta_saida,'series_reconstruidas.csv'));
for s = 1:2
    sel = strcmp(validacao.Variavel,nomes{s});
    if any(sel)
        erros = validacao.ErroRelNewtonPct(sel); erros = erros(isfinite(erros));
        fprintf('%s: %d testes ocultando um mes, MAE = %.6f %s',nomes{s}, ...
            sum(sel),mean(validacao.ErroAbsNewton(sel)),unidades{s});
        if ~isempty(erros), fprintf(', erro relativo medio = %.4f%%',mean(erros)); end
        fprintf(', max |Newton-Lagrange| = %.3g.\n', ...
            max(abs(validacao.Newton(sel)-validacao.Lagrange(sel))));
    end
end
if any(U_reconst < 0 | U_reconst > 100)
    warning('reconstrucao:limiteFisico','Ha umidades fora de [0,100]%%; inspecione as estimativas, sem truncamento automatico.');
end
resultados = struct('validacao',validacao,'grau_alto',grau_alto,'preenchidas',preenchidas);
if gerar_figuras
    fprintf('Tabelas e figuras salvas em: %s\n\n',pasta_saida);
else
    fprintf('Tabelas salvas em: %s (graficos desativados nesta chamada).\n\n',pasta_saida);
end
end
