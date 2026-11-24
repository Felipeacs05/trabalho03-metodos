function testar_interpolacao()
% Testes deterministas dos algoritmos e da selecao de falhas.
% Execute: testar_interpolacao
funcoes = {@interp_newton, @interp_lagrange};
for k = 1:numel(funcoes)
    f = funcoes{k};
    x = [3 -2 0 1]; y = 2*x.^3 - x.^2 + 4*x - 7;
    z = [-1.5 0.5; 1.5 2.5]; esperado = 2*z.^3-z.^2+4*z-7;
    obtido = f(x,y,z);
    assert(isequal(size(obtido),size(z)));
    assert(max(abs(obtido(:)-esperado(:))) < 1e-10);
    assert(max(abs(f(x,y,x)-y)) < 1e-10);
    assert(max(abs(f(x',y',z)-obtido),[],'all') < 1e-10);
    assert(isequal(f(5,12,[1 2]),[12 12]));
    assert(max(abs(f(x+1e6,y,z+1e6)-esperado),[],'all') < 1e-9);
    entradas = {{[1 1],[2 3],1}, {[1 2],[3 NaN],1}, {[1 2],3,1}};
    for j = 1:numel(entradas)
        falhou = false;
        try, f(entradas{j}{:}); catch, falhou = true; end
        assert(falhou,'Entrada invalida deveria ser rejeitada.');
    end
end
% Serie curta: bordas e falhas consecutivas permanecem NaN. A falha
% isolada tem quatro vizinhos reais; validacao preserva dados observados.
t = (1:15)'; T = 20 + t/10; U = 70-t/5;
T([1 5 10 11]) = NaN; U(8) = NaN;
datas = datenum(2000,floor((t-1)/12)+1,1) + 0*t;
pasta = tempname; mkdir(pasta);
limpeza = onCleanup(@() rmdir(pasta,'s')); %#ok<NASGU>
[Tr,Ur,r] = reconstrucao_series(t,T,U,datas,pasta);
assert(abs(Tr(5)-20.5) < 1e-10 && abs(Ur(8)-68.4) < 1e-10);
assert(all(isnan(Tr([1 10 11]))));
assert(isequal(Tr(isfinite(T)),T(isfinite(T))));
assert(all(r.preenchidas == [1;1]));
assert(max(r.validacao.ErroAbsNewton) < 1e-10);
fprintf('Todos os testes de interpolacao passaram.\n');
end
