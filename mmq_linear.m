function [coef, U_ajustado, residuos, R2, Syx] = mmq_linear(T, U, plotar)
% MMQ_LINEAR Ajuste linear U = a0 + a1*T pelo MMQ (equacoes normais).
% Entradas: T, U (vetores); plotar (opcional, padrao true)
% Saidas: coef = [a0; a1], U_ajustado, residuos, R2, Syx.
    if nargin < 3, plotar = true; end
    T = T(:); U = U(:);
    validos = isfinite(T) & isfinite(U);
    T = T(validos); U = U(validos);
    n = numel(T);
    if n < 3
        error('mmq_linear: sao necessarios pelo menos 3 pares validos.');
    end

    X = [ones(n,1), T];
    coef = (X' * X) \ (X' * U);          % equacoes normais

    U_ajustado = X * coef;
    residuos = U - U_ajustado;
    SQres = sum(residuos.^2);
    SQtot = sum((U - mean(U)).^2);
    if SQtot == 0, R2 = NaN; else, R2 = 1 - SQres/SQtot; end
    Syx = sqrt(SQres / (n - 2));

    if plotar
        [Tg, ord] = sort(T);
        figure;
        scatter(T, U, 'filled'); hold on;
        plot(Tg, U_ajustado(ord), 'LineWidth', 2);
        grid on; xlabel('Temperatura (T)'); ylabel('Umidade relativa (U)');
        title('Regressao linear: U em funcao de T');
        legend('Dados observados', 'Ajuste linear', 'Location', 'best');
        hold off;
    end

    fprintf('\n--- MMQ LINEAR ---\n');
    fprintf('U = %.6f %+.6f*T\n', coef(1), coef(2));
    fprintf('R^2 = %.6f\n', R2);
    fprintf('Erro padrao Syx = %.6f\n', Syx);
end
