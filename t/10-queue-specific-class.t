#!/usr/bin/perl

use strict;
use warnings;

use lib 't/lib';
use RT::FM::Test tests => 36;

my ( $url, $m ) = RT::Test->started_ok;
$m->login;

my %class = map { $_ => '' } qw/foo bar/;

diag "create classes foo and bar" if $ENV{TEST_VERBOSE};

for my $name ( keys %class ) {
    $m->get_ok( '/Admin/RTFM/Classes/Modify.html?Create=1',
        'class create page' );

    $m->submit_form(
        form_number => 3,
        fields      => { Name => $name }
    );

    $m->content_contains( "Editing Configuration for Class $name",
        'created class $name' );
    my ($id) = ( $m->content =~ /name="id" value="(\d+)"/ );
    ok( $id, "id of $name" );
    $class{$name} = $id;
}

diag "create articles in foo and bar" if $ENV{TEST_VERBOSE};

for my $name ( keys %class ) {
    $m->get_ok( '/RTFM/Article/Edit.html?Class=' . $class{$name},
        'article create page' );

    $m->submit_form(
        form_number => 2,
        fields      => { Name => "article $name" }
    );

    $m->content_like( qr/Article \d+ created/, "created article $name" );
}

diag "apply foo to queue General" if $ENV{TEST_VERBOSE};
{
    $m->get_ok( '/Admin/RTFM/Classes/Objects.html?id=' . $class{foo},
        'apply page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'AddClass-' . $class{foo} => 1 },
        button      => 'UpdateObjs',
    );
    $m->content_contains( 'Object created', 'applied foo to General' );
}

my $ticket_id;

diag "create ticket in General" if $ENV{TEST_VERBOSE};

{
    $m->get_ok( '/Ticket/Create.html?Queue=1', 'ticket create page' );
    $m->submit_form(
        form_number => 3,
        fields => { 'Subject' => 'test article', Content => 'test article' },
    );
    ($ticket_id) = ( $m->content =~ /Ticket \d+ created/ );
    ok( $ticket_id, "id of ticket: $ticket_id" );
}

diag "update ticket to see if there is article foo"
  if $ENV{TEST_VERBOSE};

{
    $m->get_ok( '/Ticket/Update.html?Action=Comment&id=' . $ticket_id,
        'ticket update page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RTFM_Content' => 'article' },
        button      => 'Go',
    );
    $m->content_contains( 'article foo', 'got article foo' );
    $m->content_lacks( 'article bar', 'no article bar' );
}

diag "apply bar to globally" if $ENV{TEST_VERBOSE};
{
    $m->get_ok( '/Admin/RTFM/Classes/Objects.html?id=' . $class{bar},
        'apply page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'AddClass-' . $class{bar} => 0 },
        button      => 'UpdateObjs',
    );
    $m->content_contains( 'Object created', 'applied bar globally' );
}

diag "update ticket to see if there are both article foo and bar"
  if $ENV{TEST_VERBOSE};

{
    $m->get_ok( '/Ticket/Update.html?Action=Comment&id=' . $ticket_id,
        'ticket update page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RTFM_Content' => 'article' },
        button      => 'Go',
    );
    $m->content_contains( 'article foo', 'got article foo' );
    $m->content_contains( 'article bar', 'got article bar' );
}

diag "update ticket to see if there are both article foo and bar"
  if $ENV{TEST_VERBOSE};

{
    $m->get_ok( '/Ticket/Update.html?Action=Comment&id=' . $ticket_id,
        'ticket update page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RTFM_Content' => 'article' },
        button      => 'Go',
    );
    $m->content_contains( 'article foo', 'got article foo' );
    $m->content_contains( 'article bar', 'got article bar' );
}

diag "remove both foo and bar" if $ENV{TEST_VERBOSE};
{
    $m->get_ok( '/Admin/RTFM/Classes/Objects.html?id=' . $class{foo},
        'apply page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RemoveClass-' . $class{foo} => 1 },
        button      => 'UpdateObjs',
    );
    $m->content_contains( 'Object deleted', 'removed foo' );

    $m->get_ok( '/Admin/RTFM/Classes/Objects.html?id=' . $class{bar},
        'apply page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RemoveClass-' . $class{bar} => 0 },
        button      => 'UpdateObjs',
    );
    $m->content_contains( 'Object deleted', 'remoked bar' );
}

diag "update ticket to see if there are both article foo and bar"
  if $ENV{TEST_VERBOSE};

{
    $m->get_ok( '/Ticket/Update.html?Action=Comment&id=' . $ticket_id,
        'ticket update page' );
    $m->submit_form(
        form_number => 3,
        fields      => { 'RTFM_Content' => 'article' },
        button      => 'Go',
    );
    $m->content_lacks( 'article foo', 'no article foo' );
    $m->content_lacks( 'article bar', 'no article bar' );
}
