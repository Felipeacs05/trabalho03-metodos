function validar_interpolacao(x, y, alvo)
% Validacao comum aos dois interpoladores. NaN deve ser removido antes.
if ~isnumeric(x) || ~isnumeric(y) || ~isnumeric(alvo) || ...
        ~isreal(x) || ~isreal(y) || ~isreal(alvo) || ...
        ~isvector(x) || ~isvector(y) || isempty(x) || numel(x) ~= numel(y)
    error('interpolacao:entrada', 'Use vetores reais x e y nao vazios de mesmo tamanho e alvos numericos reais.');
end
if any(~isfinite(x(:))) || any(~isfinite(y(:))) || any(~isfinite(alvo(:)))
    error('interpolacao:naoFinito', 'Nos, valores e alvos devem ser finitos.');
end
if numel(unique(x)) ~= numel(x)
    error('interpolacao:nosRepetidos', 'Os nos x devem ser distintos.');
end
end
