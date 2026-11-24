function yq = interp_lagrange(x, y, xq)
%INTERP_LAGRANGE Avalia o polinomio interpolador de Lagrange.
%   yq = interp_lagrange(x, y, xq) recebe os nos x, os valores y e o
%   ponto xq. A funcao aceita xq escalar ou vetor. Os nos devem ser
%   finitos, distintos e ter o mesmo tamanho de y.

    x = x(:);
    y = y(:);

    if numel(x) ~= numel(y) || numel(x) < 2
        error('interp_lagrange:EntradaInvalida', ...
              'x e y devem ter o mesmo numero de elementos (ao menos 2).');
    end
    if any(~isfinite(x)) || any(~isfinite(y)) || numel(unique(x)) ~= numel(x)
        error('interp_lagrange:NosInvalidos', ...
              'Os nos x e valores y devem ser finitos; os nos devem ser distintos.');
    end

    yq = zeros(size(xq));
    for i = 1:numel(x)
        Li = ones(size(xq));
        for j = 1:numel(x)
            if j ~= i
                Li = Li .* (xq - x(j)) ./ (x(i) - x(j));
            end
        end
        yq = yq + y(i) .* Li;
    end
end
