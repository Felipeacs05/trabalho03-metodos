function [coef, U_ajustado, residuos, R2, Syx] = mmq_polinomial(T, U, grau, plotar)
% MMQ_POLINOMIAL Ajuste polinomial U = a0 + a1*T + ... + agrau*T^grau (MMQ).
% Para a tarefa, usar grau = 2. coef = [a0; a1; ...; agrau].
    if nargin < 3 || isempty(grau), grau = 2; end
    if nargin < 4, plotar = true; end
    if grau < 1 || grau ~= floor(grau)
        error('O grau deve ser um inteiro positivo.');
    end
    T = T(:); U = U(:);
    validos = isfinite(T) & isfinite(U);
    T = T(validos); U = U(validos);
    n = numel(T);
    if n <= grau + 1
        error('Quantidade insuficiente de pares validos para esse grau.');
    end

    X = ones(n, grau + 1);
    for j = 1:grau
        X(:, j+1) = T.^j;
    end
    A = X' * X;
    if rcond(A) < 1e-12
        warning('mmq_polinomial: sistema mal condicionado (rcond = %.2e).', rcond(A));
    end
    coef = A \ (X' * U);                 % equacoes normais

    U_ajustado = X * coef;
    residuos = U - U_ajustado;
    SQres = sum(residuos.^2);
    SQtot = sum((U - mean(U)).^2);
    if SQtot == 0, R2 = NaN; else, R2 = 1 - SQres/SQtot; end
    Syx = sqrt(SQres / (n - (grau + 1)));

    if plotar
        Tg = linspace(min(T), max(T), 200)';   % curva suave
        Ug = polyval(flipud(coef), Tg);
        figure;
        scatter(T, U, 'filled'); hold on;
        plot(Tg, Ug, 'LineWidth', 2);
        grid on; xlabel('Temperatura (T)'); ylabel('Umidade relativa (U)');
        title(sprintf('Regressao polinomial (grau %d): U em funcao de T', grau));
        legend('Dados observados', 'Ajuste polinomial', 'Location', 'best');
        hold off;
    end

    fprintf('\n--- MMQ POLINOMIAL (GRAU %d) ---\n', grau);
    fprintf('U = %.6f', coef(1));
    for j = 1:grau
        fprintf(' %+.6f*T^%d', coef(j+1), j);
    end
    fprintf('\nR^2 = %.6f\n', R2);
    fprintf('Erro padrao Syx = %.6f\n', Syx);
end
