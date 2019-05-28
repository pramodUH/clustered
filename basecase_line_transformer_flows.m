function [poe, qoe, pde, qde, pof, qof, pdf, qdf] = basecase_line_transformer_flows(vioe, vide, thetaioe, thetaide, viof, vidf, thetaiof, thetaidf, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf)
    
    % eqn (38) page 22
    poe = (ge .* vioe.* vioe) + (-ge.*cos(thetaioe-thetaide) - be.*sin(thetaioe-thetaide)).*vioe.*vide;
    % eqn (39) page 22
    qoe = -(be + bCHe/2).*(vioe.*vioe) + (be.*cos(thetaioe-thetaide) - ge.*sin(thetaioe-thetaide)).*vioe .* vide;
    % eqn (40) page 22
    pde = ge.*(vide.* vide) + (-ge.*cos(thetaide-thetaioe) - be.*sin(thetaide-thetaioe)).*vioe.*vide;
    % eqn (41) page 22
    qde = -(be + bCHe/2).*(vide.*vide) + (be.*cos(thetaide-thetaioe) - ge.*sin(thetaide-thetaioe)).*vioe.*vide;
    % eqn (42) page 22
    pof = (gf./(tauf.*tauf) + gMf).*(viof.*viof) + (-gf./tauf.*cos(thetaiof - thetaidf - thetaf) - bf./tauf.*sin(thetaiof - thetaidf -thetaf)).*viof.*vidf;
    % eqn (43) page 22
    qof = -(bf./(tauf.*tauf) + bMf).*(viof.*viof) + (bf./tauf .* cos(thetaiof - thetaidf - thetaf) - gf ./tauf .* sin(thetaiof - thetaidf - thetaf)).* viof .* vidf;
    % eqn (44) page 22
    pdf = gf .* (vidf.*vidf) + (-gf./tauf .*cos(thetaidf - thetaiof + thetaf) - bf./tauf .*sin(thetaidf - thetaiof + thetaf)).*viof .* vidf;
    %eqn (45) page 22
    qdf = -bf.*(vidf.*vidf) + (bf ./tauf .*cos(thetaidf - thetaiof + thetaf) - gf./tauf .*sin(thetaidf - thetaiof + thetaf)).*viof .* vidf;
end