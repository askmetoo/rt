
use Test::More qw/no_plan/;
use RT;
RT::LoadConfig();
RT::Init();

{
    undef $main::_STDOUT_;
    undef $main::_STDERR_;

use_ok(RT::SavedSearches);

# The real tests are in lib/t/20savedsearch.t


    undef $main::_STDOUT_;
    undef $main::_STDERR_;
}

1;
