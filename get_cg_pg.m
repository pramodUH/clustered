function result = get_cg_pg(dispatch, linear_tables_GO, pLi, generator_mapping)
    cg = 0;
    for j=1:1:length(dispatch)
        table = linear_tables_GO{generator_mapping(j)};
        if(dispatch(j) < 0.0001)
            continue;
        elseif(table(1,1) > dispatch(j))
            cg = cg + table(1,2);
            continue;
        end
        place = sum(table(:,1) < dispatch(j))+1;
        if(place == 1)
            place = place + 1;
        elseif(place == size(table,1)+1)
            place = place - 1;
        end
        tg1 = (table(place,1) - dispatch(j))/(table(place,1) - table(place-1,1));
        if(tg1 < 0 && tg1 > -0.000001)
            tg1 = 0.0;
        elseif(tg1 > 1 && tg1 < 1.000001)
            tg1 = 1.0;
        end
        tg2 = 1 - tg1;
        calc = table(place,2)*tg2 + table(place-1,2)*tg1;
        if(tg1>=0 && tg2>=0)
            cg = cg + calc;
        else
            error('tg1 or tg2 is less than 0\n');
        end
    end
    delP=sum(dispatch)-sum(pLi);
    result = cg+100000*abs(delP);
end