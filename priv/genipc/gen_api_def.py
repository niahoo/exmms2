#!/usr/bin/env python

import sys
import types

import genipc
from indenter import Indenter

def camel_case(s):
    return ''.join(x.capitalize() for x in s.split('_'))

def elixir_val_type_to_string(term):
    if isinstance(term, genipc.TypedElement):
        return elixir_val_type_to_string(term.type[0])
    elif None == term:
        return "nil"
    elif isinstance(term, types.TupleType):
        return "{:'%s', :'%s'}" % term
    else:
        return ":'%s'" % term

def build(ipc):
    Indenter.printline('''\
# DO NOT edit this file. It is automatically generated by `mix genipc` command.
# The data is extracted from priv/genipc/ipc.xml and written as Elixir data by
# priv/genipc/gen_api_def.py.
    ''')
    Indenter.enter('%{')
    Indenter.printline('version: %s,' % ipc.version)

    Indenter.enter('enums: [')
    for enum_key in ipc.enums:
        enum = ipc.enums[enum_key]
        Indenter.enter('{:\'%s\', [' % enum.name)
        for member_name in enum.members:
            member_value = enum.members[member_name]
            Indenter.printline('{:%s, %s},' % (member_name, member_value))
        Indenter.leave(']},')
    Indenter.leave('],')

    Indenter.enter('modules: [')
    for object in ipc.objects:
        camel_name = camel_case(object.name)
        Indenter.enter('%{')
        Indenter.printline('module: "%s",' % camel_name)
        Indenter.printline("object_id: %d," % object.id)
        Indenter.enter('functions: [')
        for method in object.methods:
            emit_method_code(object, method, "")

        # for signal in object.signals:
        #     emit_method_code(object, signal, "signal_")

        for broadcast in object.broadcasts:
            emit_method_code(object, broadcast, "broadcast_")

        Indenter.leave("],")
        Indenter.leave("},")
        # Indenter.printline("xmmsclient.Client.IPC.%s = %s" % (camel_name, camel_name))
        # Indenter.printline()
    Indenter.leave("]")
    Indenter.leave("}")


def emit_method_code(object, method, name_prefix):
    method_name = name_prefix + method.name
    Indenter.enter('%{ # ' + method_name)
    Indenter.printline('name: :%s,' % method_name)
    Indenter.printline('doc: "%s",' % method.documentation)
    Indenter.printline('module: "%s",' % camel_case(object.name))
    Indenter.printline('return: %s,' % elixir_val_type_to_string(method.return_value))
    arguments = getattr(method, "arguments", [])

    Indenter.enter('args: [')


    for a in arguments:
        toptype = elixir_val_type_to_string(a.type[0])
        if len(a.type) > 1 and a.type[1] != "unknown":
            subtype = elixir_val_type_to_string(a.type[1])
            Indenter.printline('{:%s, %s, %s},'  % (a.name, toptype, subtype))
        else:
            Indenter.printline('{:%s, %s},'  % (a.name, toptype))
    Indenter.leave('],')


    if not name_prefix:
        Indenter.printline('object_id: %i,' % object.id)
        Indenter.printline('command_id: %i,' % method.id)
        s = ", ".join(('{:var, :%s}' % a.name) for a in arguments)
        Indenter.printline("payload: [%s]," % s)
    elif name_prefix == "signal_":
        Indenter.printline('object_id: 0,')
        Indenter.printline('command_id: 32,')
        Indenter.printline('payload: [{:const, %i}],' % method.id)
    elif name_prefix == "broadcast_":
        Indenter.printline('object_id: 0,')
        Indenter.printline('command_id: 33,')
        Indenter.printline("payload: [{:const, %i}]," % method.id)

    if name_prefix == "signal_":
        Indenter.printline('signal: true,')
    else:
        Indenter.printline('signal: false,')

    Indenter.leave('},')
    Indenter.printline()
    return

sys.stderr.write("Using IPC definition from %s\n" % sys.argv[1])
ipc = genipc.parse_xml(sys.argv[1])
build(ipc)
