function result = identify_end(string)
    w = strtok(string, '/');
    [token, rem] = strtok(w);
    token2 = strtok(rem);
    if(length(token) == 1 && token(1) == '0' && isempty(token2))
        result = 1;
        return;
    end
    result = 0;
end