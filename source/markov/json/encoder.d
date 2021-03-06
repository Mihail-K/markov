
module markov.json.encoder;

import markov.chain;
import markov.counter;
import markov.serialize;
import markov.state;

import std.algorithm;
import std.array;
import std.conv;
import std.json;
import std.stdio;
import std.string;

struct JsonEncoder(T)
{
private:
    bool _pretty;

public:
    this(bool pretty)
    {
        _pretty = pretty;
    }

    string encode(ref MarkovChain!T chain)
    {
        JSONValue states = chain.states.map!(s => encodeState(s)).array;

        return toJSON(states, _pretty);
    }

private:
    JSONValue encodeState(State!T state)
    {
        JSONValue object = ["size": state.size.text];
        object["counters"] = "{ }".parseJSON;

        foreach(first; state.keys)
        {
            object["counters"][encodeKeys(first)] = encodeCounter(state.get(first));
        }

        return object;
    }

    JSONValue encodeCounter(Counter!T counter)
    {
        string[string] data;

        foreach(follow; counter.keys)
        {
            data[encodeKey(follow)] = counter.get(follow).text;
        }

        JSONValue object = data;
        return object;
    }

    string encodeKeys(T[] keys)
    {
        return "[%(%s,%)]".format(keys.map!(k => encodeKey(k)));
    }

    string encodeKey(T key)
    {
        static if(hasEncodeProperty!(T, string))
        {
            return key.encode;
        }
        else
        {
            return key.text;
        }
    }
}

string encodeJSON(T)(ref MarkovChain!T chain, bool pretty = false)
{
    JsonEncoder!T encoder = JsonEncoder!T(pretty);
    return encoder.encode(chain);
}

void encodeJSON(T)(ref MarkovChain!T chain, File output, bool pretty = false)
{
    output.write(chain.encodeJSON(pretty));
}
