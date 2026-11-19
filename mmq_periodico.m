function [coef, y_ajust, residuos, R2, Syx] = mmq_periodico(t, y, P)
% MMQ_PERIODICO Ajusta modelo periodico linearizado via Minimos Quadrados.
% Modelo: y(t) = a0 + a1*cos(w*t) + b1*sin(w*t), onde w = 2*pi/P.
%
% Entradas:
%   t -> vetor de tempo (meses sequenciais 1, 2, ..., N)
%   y -> vetor da variavel climatica (T ou U); valores NaN sao ignorados no ajuste
%   P -> periodo fundamental do ciclo (ex.: 12 para ciclo anual em meses)
%
% Saidas:
%   coef    -> [a0; a1; b1]
%   y_ajust -> curva periodica ajustada avaliada em todo o vetor t
%   residuos-> y - y_ajust (mantem NaN onde y era NaN)
%   R2      -> coeficiente de determinacao sobre os pontos validos
%   Syx     -> erro padrao da estimativa: sqrt(Sr / (n_validos - 3))

if nargin < 3
    error('mmq_periodico requer 3 argumentos: (t, y, P).');
end
if ~isscalar(P) || ~isnumeric(P) || P <= 0
    error('O periodo P deve ser um escalar positivo.');
end

t = double(t(:));
y = double(y(:));

if length(t) ~= length(y)
    error('Os vetores t e y devem ter o mesmo comprimento.');
end

% Filtra observacoes validas (evita propagacao de NaN nas somatorias do MMQ)
valid = ~isnan(t) & ~isnan(y);
n_val = sum(valid);

if n_val < 3
    error('Sao necessarios pelo menos 3 pontos validos para ajustar o modelo periodico.');
end

t_val = t(valid);
y_val = y(valid);

w = 2 * pi / P;
c_val = cos(w * t_val);
s_val = sin(w * t_val);

% Montagem do sistema linear normal 3x3 (A * coef = B)
A = [ n_val,       sum(c_val),      sum(s_val);
      sum(c_val),  sum(c_val.^2),   sum(c_val .* s_val);
      sum(s_val),  sum(c_val .* s_val), sum(s_val.^2) ];

B = [ sum(y_val);
      sum(y_val .* c_val);
      sum(y_val .* s_val) ];

% Resolucao do sistema (coef = [a0; a1; b1])
coef = A \ B;

% Avaliacao da curva continua sobre todo o eixo t
y_ajust = coef(1) + coef(2) * cos(w * t) + coef(3) * sin(w * t);
residuos = y - y_ajust;

% Metricas de ajuste calculadas apenas nos pontos observados
res_val = y_val - y_ajust(valid);
St = sum((y_val - mean(y_val)).^2);
Sr = sum(res_val.^2);

if St == 0
    R2 = 0;
else
    R2 = (St - Sr) / St;
end

if n_val > 3
    Syx = sqrt(Sr / (n_val - 3));
else
    Syx = NaN;
end
end
