ALTER EXTENSION explanation ADD FUNCTION explanation(text,boolean,text[]);
ALTER EXTENSION explanation ADD FUNCTION parse_node(text[],xml,text,interval,trigger_plan[]);
ALTER EXTENSION explanation ADD FUNCTION parse_node(xml,text,interval,trigger_plan[]);
ALTER EXTENSION explanation ADD FUNCTION parse_triggers(xml[]);
ALTER EXTENSION explanation ADD TYPE     trigger_plan;
