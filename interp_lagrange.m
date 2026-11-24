function y_interp = interp_lagrange(x_conhecidos, y_conhecidos, x_alvo)
% INTERP_LAGRANGE Soma explicita dos polinomios base de Lagrange.
% L_i(x) = produto_{j ~= i} (x-x_j)/(x_i-x_j).
% Implementacao manual; preserva o formato de x_alvo.
validar_interpolacao(x_conhecidos, y_conhecidos, x_alvo);
x = double(x_conhecidos(:));
y = double(y_conhecidos(:));
centro = x(1);
escala = max(abs(x - centro));
if escala == 0, escala = 1; end
x = (x - centro) / escala;
z = (double(x_alvo) - centro) / escala;
y_interp = zeros(size(z));
for i = 1:numel(x)
    base = ones(size(z));
    for j = 1:numel(x)
        if j ~= i
            base = base .* (z - x(j)) / (x(i) - x(j));
        end
    end
    y_interp = y_interp + y(i) * base;
end
end
