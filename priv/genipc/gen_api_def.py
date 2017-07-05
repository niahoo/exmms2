#!/usr/bin/env python

import sys

import genipc
from indenter import Indenter

def camel_case(s):
    return ''.join(x.capitalize() for x in s.split('_'))

def build(ipc):
    Indenter.printline('# This file is automatically generated. Do not edit.')
    Indenter.enter('%{')
    Indenter.printline('version: %s,' % ipc.version)
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
    Indenter.printline('doc: "%s",' % method.documentation)
    Indenter.printline('name: :%s,' % method_name)
    arguments = getattr(method, "arguments", [])

    Indenter.enter('args: [')


    for a in arguments:
        toptype = a.type[0].replace('enum-value', 'enum_value')
        if len(a.type) > 1 and a.type[1] != "unknown":
            subtype = a.type[1]
            Indenter.printline('{:%s, :%s, :%s},'  % (a.name, toptype, subtype))
        else:
            Indenter.printline('{:%s, :%s},'  % (a.name, toptype))
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
