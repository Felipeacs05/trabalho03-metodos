function y_interp = interp_newton(x_conhecidos, y_conhecidos, x_alvo)
% INTERP_NEWTON Interpolacao por diferencas divididas, sem funcoes prontas.
% Aceita nos em qualquer ordem e preserva o formato de x_alvo.
% N nos distintos definem um polinomio de grau no maximo N-1.
validar_interpolacao(x_conhecidos, y_conhecidos, x_alvo);
x = double(x_conhecidos(:));
a = double(y_conhecidos(:));
n = numel(x);
% Centrar e escalar reduz efeitos de unidades e datas grandes; nao elimina
% as oscilacoes intrinsecas de um polinomio global de grau elevado.
centro = x(1);
escala = max(abs(x - centro));
if escala == 0, escala = 1; end
x = (x - centro) / escala;
z = (double(x_alvo) - centro) / escala;
% Atualizacao de tras para frente preserva a coluna anterior da tabela.
for ordem = 1:n-1
    for i = n:-1:ordem+1
        a(i) = (a(i) - a(i-1)) / (x(i) - x(i-ordem));
    end
end
% Avaliacao aninhada da forma de Newton (Horner generalizado).
y_interp = a(n) * ones(size(z));
for i = n-1:-1:1
    y_interp = a(i) + (z - x(i)) .* y_interp;
end
end
