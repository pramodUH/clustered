function csigma = get_csigma(pg, qg, v, theta, branch_data_GO, transformer_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, bus_info, pLi, qLi, gFSi, bFSi, bCSi, no_of_busses, Rbare, Sbarf, lambdaPn, lambdaQn, lambdaen, limits)

    origin = branch_data_GO(:,1);
    destination = branch_data_GO(:,2);
    vioe = zeros(size(origin,1),1);
    vide = zeros(size(destination,1),1);
    thetaioe = zeros(size(origin,1),1);
    thetaide = zeros(size(destination,1),1);
    for j=1:1:size(branch_data_GO,1)
        vioe(j) = v(origin(j));
        vide(j) = v(destination(j));
        thetaioe(j) = theta(origin(j));
        thetaide(j) = theta(destination(j));
    end
    origin = transformer_data_GO(:,1);
    destination = transformer_data_GO(:,2);
    viof = zeros(size(origin,1),1);
    vidf = zeros(size(destination,1),1);
    thetaiof = zeros(size(origin,1),1);
    thetaidf = zeros(size(destination,1),1);

    for j=1:1:size(transformer_data_GO,1)
        viof(j) = v(origin(j));
        vidf(j) = v(destination(j));
        thetaiof(j) = theta(origin(j));
        thetaidf(j) = theta(destination(j));
    end
    [poe, qoe, pde, qde, pof, qof, pdf, qdf] = basecase_line_transformer_flows(vioe,vide, thetaioe, thetaide, viof, vidf, thetaiof, thetaidf, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf);
    [sigmaPplusi, sigmaPminusi, sigmaQplusi, sigmaQminusi] = bus_power_balance_constraints(bus_info, pg, qg, pLi, qLi, gFSi, bFSi, bCSi, v, poe, pde, pof, pdf, qoe, qde, qof, qdf, no_of_busses);
    [sigmase, sigmafe] = basecase_line_transformer_ratings(poe, qoe, pde, qde, vioe, vide, pof, qof, pdf, qdf, Rbare, Sbarf);
    csigma = penalty_with_no_contingencies(sigmaPplusi, sigmaPminusi, sigmaQplusi, sigmaQminusi, sigmase, sigmafe, lambdaPn, lambdaQn, lambdaen, limits);
    

end
