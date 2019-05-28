function [sigmase, sigmafe] = basecase_line_transformer_ratings(poe, qoe, pde, qde, vioe, vide, pof, qof, pdf, qdf, Rbare, Sbarf)

    % eqn (52) pg. 23
    t1 = sqrt((poe .* poe) + (qoe .* qoe)) - Rbare .* vioe;
    % eqn (54) pg. 23 
    t2 = sqrt((pde .* pde) + (qde .* qde)) - Rbare .* vide;
    sigmase = max(t1, t2);
    sigmase(sigmase<0) = 0;
    % eqn (55) pg. 24 
    t1 = sqrt((pof .* pof) + (qof .* qof)) - Sbarf;
    % eqn (57) pg. 24
    t2 = sqrt((pdf .* pdf) + (qdf .* qdf)) - Sbarf;
    sigmafe = max(t1, t2);
    sigmafe(sigmafe<0) = 0;
end
