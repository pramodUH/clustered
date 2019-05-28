function qg = get_qg(v, theta, bus_info, qLi, branch_data_GO, transformer_data_GO, generator_data_GO, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf, SBASE)

    no_of_generators = size(generator_data_GO,1);
    
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
    
    [~, qoe, ~, qde, ~, qof, ~, qdf] = basecase_line_transformer_flows(vioe,vide, thetaioe, thetaide, viof, vidf, thetaiof, thetaidf, ge, be, thetaf, bCHe, gf, bf, tauf, gMf, bMf);
    %[~, ~, sigmaQplusi, sigmaQminusi] = bus_power_balance_constraints(bus_info, pg, qg, pLi, qLi, gFSi, bFSi, bCSi, v, poe, pde, pof, pdf, qoe, qde, qof, qdf, no_of_busses);
    %csigma_q = sum([sigmaQplusi; -sigmaQminusi]);    
    q_cal = zeros(no_of_generators, 1);
    for i = 1:1:size(generator_data_GO,1)
    bus_index = generator_data_GO(i,1);
    origin_list = bus_info(bus_index).origin_list;
    for j = 1:1:size(origin_list,2)
        q_cal(i) = q_cal(i) + qoe(origin_list(j));
    end
    destination_list = bus_info(bus_index).destination_list;
    for j = 1:1:size(destination_list,2)
        q_cal(i) = q_cal(i) + qde(destination_list(j));
    end
    transformer_origin_list = bus_info(bus_index).transformer_origin_list;
    for j = 1:1:size(transformer_origin_list,2)
        q_cal(i) = q_cal(i) + qof(transformer_origin_list(j));
    end
    transformer_destination_list = bus_info(bus_index).transformer_destination_list;
    for j = 1:1:size(transformer_destination_list,2)
        q_cal(i) = q_cal(i) + qdf(transformer_destination_list(j));
    end 
        q_cal(i) = q_cal(i) + qLi(bus_index);
    end

    qg = q_cal;

    for i = 1:1:no_of_generators
        if(qg(i) > generator_data_GO(i,4)/SBASE)
            qg(i) = generator_data_GO(i,4)/SBASE;
        elseif(qg(i) < generator_data_GO(i,5)/SBASE)
            qg(i) = generator_data_GO(i,5)/SBASE;
        end
    end
end