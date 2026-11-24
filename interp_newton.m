function yq = interp_newton(x, y, xq)
%INTERP_NEWTON Avalia o polinomio interpolador de Newton.
%   yq = interp_newton(x, y, xq) recebe os nos x, os valores y e o
%   ponto xq. A funcao usa diferencas divididas e aceita xq escalar ou
%   vetor. Os nos devem ser finitos, distintos e ter o mesmo tamanho de y.

    x = x(:);
    y = y(:);

    if numel(x) ~= numel(y) || numel(x) < 2
        error('interp_newton:EntradaInvalida', ...
              'x e y devem ter o mesmo numero de elementos (ao menos 2).');
    end
    if any(~isfinite(x)) || any(~isfinite(y)) || numel(unique(x)) ~= numel(x)
        error('interp_newton:NosInvalidos', ...
              'Os nos x e valores y devem ser finitos; os nos devem ser distintos.');
    end

    n = numel(x);
    coef = y;
    for ordem = 2:n
        coef(ordem:n) = (coef(ordem:n) - coef(ordem-1:n-1)) ./ ...
                         (x(ordem:n) - x(1:n-ordem+1));
    end

    yq = coef(n) * ones(size(xq));
    for k = n-1:-1:1
        yq = coef(k) + (xq - x(k)) .* yq;
    end
end
